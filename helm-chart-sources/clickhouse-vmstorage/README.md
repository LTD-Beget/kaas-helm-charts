# Конфигурация Clickhouse
Clickhouse может принимать [Prometheus](https://clickhouse.com/docs/interfaces/prometheus) метрики и писать в TSDB.
Для этого нужно:
1. Добавить БД metrics и таблицу на движке TimeSeries
```
CREATE DATABASE IF NOT EXISTS metrics;

SET allow_experimental_time_series_table = 1;

CREATE TABLE IF NOT EXISTS metrics.ts ENGINE = TimeSeries;
```
2. Добавить конфигуационный файл, где описывается handler на прием метрик
```
<yandex>
<prometheus>
    <port>9363</port>

    <handlers>
    <remote_write>
        <url>/promrw</url>
        <handler>
        <type>remote_write</type>
        <database>metrics</database>
        <table>ts</table>
        </handler>
    </remote_write>

    <metrics>
        <url>/metrics</url>
        <handler>
        <type>expose_metrics</type>
        </handler>
    </metrics>

    </handlers>
</prometheus>
</yandex>
```
3. Настройка отдельного инстанса vmAlert на отправку расчитанных метрик в Clickhouse
Для этого в конфигурации vmAlert нужно указать remoteWrite актуальный адрес, порт и путь (в соотвествии с параметрами, указанными в handler)
```
remoteWrite:
  url: "http://clickhouse:9363/promrw"
```
4. Описать правила vmrule для этого vmAlert для вычисления, фильтрации и обогащения метрик
Актуальные правила можно посмотреть в текущем репозитории по пути [helm-chart-sources/victoria-metrics-k8s-stack/templates/clickhouse-inserter/vmrules.yaml](../../helm-chart-sources/victoria-metrics-k8s-stack/templates/clickhouse-inserter/vmrules.yaml)


# Схема БД
При выполнении команд
```
CREATE DATABASE IF NOT EXISTS metrics;

SET allow_experimental_time_series_table = 1;

CREATE TABLE IF NOT EXISTS metrics.ts ENGINE = TimeSeries;
```
Создается таблица metrics.ts (и 3 вспомогательные)
```
CREATE TABLE metrics.ts
(
  `id` UUID DEFAULT reinterpretAsUUID(sipHash128(metric_name, all_tags)),
  `timestamp` DateTime64(3),
  `value` Float64,
  `metric_name` LowCardinality(String),
  `tags` Map(LowCardinality(String), String),
  `all_tags` Map(String, String),
  `min_time` Nullable(DateTime64(3)),
  `max_time` Nullable(DateTime64(3)),
  `metric_family_name` String,
  `type` String,
  `unit` String,
  `help` String
)
ENGINE = TimeSeries DATA
ENGINE = MergeTree
ORDER BY (id, timestamp) TAGS
ENGINE = AggregatingMergeTree
PRIMARY KEY metric_name
ORDER BY (metric_name, id) METRICS
ENGINE = ReplacingMergeTree
ORDER BY metric_family_name
```
metrics.ts — хранилище метрик на ClickHouse Engine=TimeSeries.
Идентификатор серии (id) вычисляется как UUID из sipHash128(metric_name, all_tags).
Движок создаёт несколько внутренних таблиц: 
- DATA (MergeTree, сортировка (id, timestamp)) для сырых точек, 
- TAGS (AggregatingMergeTree, ключ по metric_name) служебное хранилище для тэгов/серий
- METRICS (ReplacingMergeTree) для описаний метрик (help, type, unit, family).
Из-за вычисления id кардинальность серий напрямую зависит от количества уникальных комбинаций metric_name + tags; поэтому запрещены высококардинальные теги (request_id/trace_id и т.п.).

# Метрики
## Метрики групп нод
Метрики и примеры графиков можно посмотреть в графане на дашборде beget-grafana -> ClickhouseTSDB / Nodegroups (по пути https://GRAFANA_ADDR/grafana/d/clickhouse-tsdb-nodegroups)

### beget_nodegroup_memory_used_mb
#### Описание
Общее потребление RAM на группу нод
#### Лейблы
- cluster
- nodegroup
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
sum by (cluster, nodegroup) (
  (
    (
      avg by (cluster, instance) (
        label_replace(
          (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes),
          "cluster", "$1", "cluster_full_name", "(.*)"
        )
      )
      * on(instance) group_left(nodename)
      node_uname_info
    ) / 1024 / 1024
  )
  * on(nodename) group_left(nodegroup)
  max by (nodename, nodegroup) (
    label_replace(
      label_replace(
        kube_node_labels,
        "nodename", "$1", "node", "(.*)"
      ),
      "nodegroup", "$1", "label_kubernetes_io_os", "(.*)"
    )
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 60 SECOND) AS time,
  t.tags['nodegroup'] AS metric,
  avg(d.value) AS USAGE
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_nodegroup_memory_used_mb'
  AND d.timestamp >= toDateTime(1770542576) AND d.timestamp <= toDateTime(1770542876)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodegroup'] IN ('linux')
GROUP BY time, metric
ORDER BY time;
```

### beget_nodegroup_memory_total_mb
#### Описание
Общий объем RAM на группу нод
#### Лейблы
- cluster
- nodegroup
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
sum by (cluster, nodegroup) (
  (
    (
      avg by (cluster, nodename) (
        label_replace(
          node_memory_MemTotal_bytes,
          "cluster", "$1", "cluster_full_name", "(.*)"
        )
        * on(instance) group_left(nodename)
        node_uname_info
      )
    ) / 1024 / 1024
  )
  * on(nodename) group_left(nodegroup)
  max by (nodename, nodegroup) (
    label_replace(
      label_replace(
        kube_node_labels,
        "nodename", "$1", "node", "(.*)"
      ),
      "nodegroup", "$1", "label_kubernetes_io_os", "(.*)"
    )
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 60 SECOND) AS time,
  t.tags['nodegroup'] AS metric,
  avg(d.value) AS TOTAL
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_nodegroup_memory_total_mb'
  AND d.timestamp >= toDateTime(1770500419) AND d.timestamp <= toDateTime(1770543619)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodegroup'] IN ('linux')
GROUP BY time, metric
ORDER BY time;
```

### beget_nodegroup_cpu_used_cores
#### Описание
Общая утилизация CPU на группу нод
#### Лейблы
- cluster
- nodegroup
#### Значения
В ядрах
#### Как вычисляется в vmAlert
```
sum by (cluster, nodegroup) (
  (
    sum by (cluster, nodename) (
      rate(
        label_replace(
          node_cpu_seconds_total{mode!~"idle|iowait|steal"},
          "cluster", "$1", "cluster_full_name", "(.*)"
        )[5m]
      )
      * on(instance) group_left(nodename)
      node_uname_info
    )
  )
  * on(nodename) group_left(nodegroup)
  max by (nodename, nodegroup) (
    label_replace(
      label_replace(
        kube_node_labels,
        "nodename", "$1", "node", "(.*)"
      ),
      "nodegroup", "$1", "label_kubernetes_io_os", "(.*)"
    )
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 30 SECOND) AS time,
  t.tags['nodegroup'] AS metric,
  avg(d.value) AS USAGE
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_nodegroup_cpu_used_cores'
  AND d.timestamp >= toDateTime(1770500419) AND d.timestamp <= toDateTime(1770543619)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodegroup'] IN ('linux')
GROUP BY time, metric
ORDER BY time;
```

### beget_nodegroup_cpu_total_cores
#### Описание
Общее количество CPU на группу нод
#### Лейблы
- cluster
- nodegroup
#### Значения
В ядрах
#### Как вычисляется в vmAlert
```
sum by (cluster, nodegroup) (
  count by (cluster, nodename, nodegroup) (
    (
      label_replace(
        node_cpu_seconds_total{mode="idle"},
        "cluster", "$1", "cluster_full_name", "(.*)"
      )
      * on(instance) group_left(nodename)
      node_uname_info
    )
    * on(nodename) group_left(nodegroup)
    max by (nodename, nodegroup) (
      label_replace(
        label_replace(
          kube_node_labels,
          "nodename", "$1", "node", "(.*)"
        ),
        "nodegroup", "$1", "label_kubernetes_io_os", "(.*)"
      )
    )
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 30 SECOND) AS time,
  t.tags['nodegroup'] AS metric,
  avg(d.value) AS TOTAL
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_nodegroup_cpu_total_cores'
  AND d.timestamp >= toDateTime(1770500419) AND d.timestamp <= toDateTime(1770543619)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodegroup'] IN ('linux')
GROUP BY time, metric
ORDER BY time;
```

### beget_nodegroup_filesystem_used_mb
#### Описание
Общее потребление дискового пространства на группу нод
#### Лейблы
- cluster
- nodegroup
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
sum by (cluster, nodegroup) (
  (
    (
      avg by (cluster, instance, device, fstype) (
        label_replace(
          (
            node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}
            -
            node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}
          ),
          "cluster", "$1", "cluster_full_name", "(.*)"
        )
      )
      * on(instance) group_left(nodename)
      node_uname_info
    ) / 1024 / 1024
  )
  * on(nodename) group_left(nodegroup)
  max by (nodename, nodegroup) (
    label_replace(
      label_replace(
        kube_node_labels,
        "nodename", "$1", "node", "(.*)"
      ),
      "nodegroup", "$1", "label_kubernetes_io_os", "(.*)"
    )
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 30 SECOND) AS time,
  t.tags['nodegroup'] AS metric,
  avg(d.value) AS USAGE
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_nodegroup_filesystem_used_mb'
  AND d.timestamp >= toDateTime(1770500419) AND d.timestamp <= toDateTime(1770543619)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodegroup'] IN ('linux')
GROUP BY time, metric
ORDER BY time;
```

### beget_nodegroup_filesystem_total_mb
#### Описание
Общий объем дискового пространства на группу нод
#### Лейблы
- cluster
- nodegroup
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
sum by (cluster, nodegroup) (
  (
    (
      avg by (cluster, instance, device, fstype) (
        label_replace(
          node_filesystem_size_bytes{mountpoint="/", fstype!~"tmpfs|overlay|squashfs"},
          "cluster", "$1", "cluster_full_name", "(.*)"
        )
      )
      * on(instance) group_left(nodename)
      node_uname_info
    ) / 1024 / 1024
  )
  * on(nodename) group_left(nodegroup)
  max by (nodename, nodegroup) (
    label_replace(
      label_replace(
        kube_node_labels,
        "nodename", "$1", "node", "(.*)"
      ),
      "nodegroup", "$1", "label_kubernetes_io_os", "(.*)"
    )
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 30 SECOND) AS time,
  t.tags['nodegroup'] AS metric,
  avg(d.value) AS TOTAL
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_nodegroup_filesystem_total_mb'
  AND d.timestamp >= toDateTime(1770500419) AND d.timestamp <= toDateTime(1770543619)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodegroup'] IN ('linux')
GROUP BY time, metric
ORDER BY time;
```

## Метрики нод
Метрики и примеры графиков можно посмотреть в графане на дашборде beget-grafana -> ClickhouseTSDB / Nodes (по пути https://GRAFANA_ADDR/grafana/d/clickhouse-tsdb-nodes)

### beget_node_memory_used_mb
#### Описание
Потребление RAM на ноде
#### Лейблы
- cluster
- nodename
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
(
  avg by (cluster, instance) (
    label_replace(
      (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes),
      "cluster", "$1", "cluster_full_name", "(.*)"
    )
  ) * on(instance) group_left(nodename) node_uname_info
) / 1024 / 1024
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 15 SECOND) AS time,
  t.tags['nodename'] AS metric,
  avg(d.value) AS USAGE
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_node_memory_used_mb'
  AND d.timestamp >= toDateTime(1770524118) AND d.timestamp <= toDateTime(1770545718)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodename'] IN ('apmistcs-system-2-infra-bdwxn-2djm2')
GROUP BY time, metric
ORDER BY time;
```

### beget_node_memory_total_mb
#### Описание
Объем RAM на ноде
#### Лейблы
- cluster
- nodename
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
(
  avg by (cluster, instance) (
    label_replace(
      node_memory_MemTotal_bytes{},
      "cluster", "$1", "cluster_full_name", "(.*)"
    )
  ) * on(instance) group_left(nodename) node_uname_info
) / 1024 / 1024
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 15 SECOND) AS time,
  t.tags['nodename'] AS metric,
  avg(d.value) AS TOTAL
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_node_memory_total_mb'
  AND d.timestamp >= toDateTime(1770524118) AND d.timestamp <= toDateTime(1770545718)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodename'] IN ('apmistcs-system-2-infra-bdwxn-2djm2')
GROUP BY time, metric
ORDER BY time;
```

### beget_node_cpu_used_cores
#### Описание
Утилизация CPU на ноде
#### Лейблы
- cluster
- nodename
#### Значения
В ядрах
#### Как вычисляется в vmAlert
```
sum by (cluster, nodename) (
  rate(
    label_replace(
      node_cpu_seconds_total{mode!~"idle|iowait|steal"},
      "cluster", "$1", "cluster_full_name", "(.*)"
    )[5m]
  )
  * on(instance) group_left(nodename)
  node_uname_info
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 15 SECOND) AS time,
  t.tags['nodename'] AS metric,
  avg(d.value) AS USAGE
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_node_cpu_used_cores'
  AND d.timestamp >= toDateTime(1770524118) AND d.timestamp <= toDateTime(1770545718)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodename'] IN ('apmistcs-system-2-infra-bdwxn-2djm2')
GROUP BY time, metric
ORDER BY time;
```

### beget_node_cpu_total_cores
#### Описание
Количество CPU на ноде
#### Лейблы
- cluster
- nodename
#### Значения
В ядрах
#### Как вычисляется в vmAlert
```
count by (cluster, nodename) (
  label_replace(
    node_cpu_seconds_total{mode="idle"},
    "cluster", "$1", "cluster_full_name", "(.*)"
  )
  * on(instance) group_left(nodename)
  node_uname_info
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 15 SECOND) AS time,
  t.tags['nodename'] AS metric,
  avg(d.value) AS TOTAL
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_node_cpu_total_cores'
  AND d.timestamp >= toDateTime(1770524118) AND d.timestamp <= toDateTime(1770545718)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodename'] IN ('apmistcs-system-2-infra-bdwxn-2djm2')
GROUP BY time, metric
ORDER BY time;
```

### beget_node_filesystem_used_mb
#### Описание
Потребление дискового пространства на ноде
#### Лейблы
- cluster
- nodename
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
(
  avg by (cluster, instance, device, fstype) (
    label_replace(
      (node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"} - node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}),
      "cluster", "$1", "cluster_full_name", "(.*)"
    )
  ) * on(instance) group_left(nodename) node_uname_info
) / 1024 / 1024
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 15 SECOND) AS time,
  t.tags['nodename'] AS metric,
  avg(d.value) AS USAGE
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_node_filesystem_used_mb'
  AND d.timestamp >= toDateTime(1770524118) AND d.timestamp <= toDateTime(1770545718)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodename'] IN ('apmistcs-system-2-infra-bdwxn-2djm2')
GROUP BY time, metric
ORDER BY time;
```

### beget_node_filesystem_total_mb
#### Описание
Объем дискового пространства на ноде
#### Лейблы
- cluster
- nodename
#### Значения
В мегабайтах
#### Как вычисляется в vmAlert
```
(
  avg by (cluster, instance, device, fstype) (
    label_replace(
      node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"},
      "cluster", "$1", "cluster_full_name", "(.*)"
    )
  ) * on(instance) group_left(nodename) node_uname_info
) / 1024 / 1024
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 15 SECOND) AS time,
  t.tags['nodename'] AS metric,
  avg(d.value) AS TOTAL
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_node_filesystem_total_mb'
  AND d.timestamp >= toDateTime(1770524118) AND d.timestamp <= toDateTime(1770545718)
  AND t.tags['cluster']  IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['nodename'] IN ('apmistcs-system-2-infra-bdwxn-2djm2')
GROUP BY time, metric
ORDER BY time;
```













### beget_nodegroup_cpu_total_cores
#### Описание
Общее количество CPU на группу нод
#### Лейблы
- cluster
- nodegroup
#### Значения
В ядрах
#### Как вычисляется в vmAlert
```

```
#### Пример запроса в Clikhouse
```

```


## Рекомендации
1. В запросах требуется указывать временные промежутки и интервалы.
2. Интервал рекомендуется вычислять исходя из выбранного временного отрезка, чтобы на больших периодах не делать тяжелых запросов и не получать излишне много значений
