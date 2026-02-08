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
      "nodegroup", "$1", "label_node_group_beget_com_name", "(.*)"
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
      "nodegroup", "$1", "label_node_group_beget_com_name", "(.*)"
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
      "nodegroup", "$1", "label_node_group_beget_com_name", "(.*)"
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
        "nodegroup", "$1", "label_node_group_beget_com_name", "(.*)"
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
      "nodegroup", "$1", "label_node_group_beget_com_name", "(.*)"
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
      "nodegroup", "$1", "label_node_group_beget_com_name", "(.*)"
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

## Метрики Pod'ов
Метрики и примеры графиков можно посмотреть в графане на дашборде beget-grafana -> ClickhouseTSDB / Pods (по пути https://GRAFANA_ADDR/grafana/d/clickhouse-tsdb-pods)


### beget_pod_status_phase
#### Описание
Информация о статусе Pod'ы
#### Лейблы
- cluster
- container
- namespace
- phase
- pod
#### Значения
cluster:    string
container:  string
namespace:  string
phase:      Enum(Failed,Pending,Running,Succeeded,Unknown)
pod:        string
#### Как вычисляется в vmAlert
```
group by (cluster, namespace, phase, pod, container) (
  label_replace(
    kube_pod_status_phase{pod!="", namespace!=""},
    "cluster", "$1", "cluster_full_name", "(.*)"
  )
)
```
#### Пример запроса в Clikhouse
```
WITH last AS (
  SELECT
    t.tags['cluster']   AS cluster,
    t.tags['namespace'] AS namespace,
    t.tags['pod']       AS pod,
    t.tags['phase']     AS phase,
    argMax(d.value, d.timestamp) AS v,
    max(d.timestamp) AS ts
  FROM timeSeriesData(metrics.ts) AS d
  INNER JOIN timeSeriesTags(metrics.ts) AS t
    ON t.id = d.id
  WHERE
    t.metric_name = 'beget_pod_status_phase'
    AND d.timestamp >= toDateTime(1770506450) AND d.timestamp <= toDateTime(1770549650)
    AND t.tags['cluster']   IN ('dlputim6-apmistcs-system-2-infra')
    AND t.tags['namespace'] IN ('apmistcs')
    AND t.tags['pod']       IN ('apmistcs-system-2-infra-cloud-controller-manager-8f45949d-2qldc')
  GROUP BY cluster, namespace, pod, phase
)
SELECT
  cluster,
  namespace,
  pod,
  phase,
  ts
FROM last
WHERE v = 1
ORDER BY cluster, namespace, pod, phase;
```

### beget_pod_restarts_total
#### Описание
Общее количество рестартов на pod
#### Лейблы
- cluster
- container
- namespace
- pod
#### Значения
Счетчик
#### Как вычисляется в vmAlert
```
max by (cluster, namespace, phase, pod, container) (
  label_replace(
    kube_pod_container_status_restarts_total{pod!="", namespace!=""},
    "cluster", "$1", "cluster_full_name", "(.*)"
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  t.tags['cluster']   AS cluster,
  t.tags['namespace'] AS namespace,
  t.tags['pod']       AS pod,
  t.tags['phase']     AS phase,
  argMax(d.value, d.timestamp) AS restarts_total,
  max(d.timestamp) AS ts
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_pod_restarts_total'
  AND d.timestamp >= toDateTime(1770506541) AND d.timestamp <= toDateTime(1770549741)
  AND t.tags['cluster']   IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['namespace'] IN ('apmistcs')
  AND t.tags['pod']       IN ('apmistcs-system-2-infra-cloud-controller-manager-8f45949d-2qldc')
GROUP BY cluster, namespace, pod, phase
ORDER BY restarts_total DESC;
```

### beget_pod_info
#### Описание
Информация о Pod'е
#### Лейблы
- cluster
- container
- created_by_kind
- created_by_name
- host_ip
- host_network
- namespace
- node
- pod
- pod_ip
- priority_class
#### Значения
cluster:          string
container:        string
created_by_kind:  Enum(ReplicaSet,StatefulSet,DaemonSet,CronJob,Job)
created_by_name:  string
host_ip:          string
host_network:     Enum(true/false)
namespace:        string
pod:              string
pod_ip:           string
phase:            Enum(Failed,Pending,Running,Succeeded,Unknown)
node:             string
priority_class:   string
#### Как вычисляется в vmAlert
```
(
  label_replace(
    kube_pod_info{pod!="", namespace!=""},
    "cluster", "$1", "cluster_full_name", "(.*)"
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  t.tags['cluster']          AS cluster,
  t.tags['namespace']        AS namespace,
  t.tags['pod']              AS pod,
  t.tags['container']        AS container,
  t.tags['phase']            AS phase,

  t.tags['created_by_kind']  AS created_by_kind,
  t.tags['created_by_name']  AS created_by_name,

  t.tags['node']             AS node,
  t.tags['host_ip']          AS host_ip,
  t.tags['pod_ip']           AS pod_ip,
  t.tags['host_network']     AS host_network,
  t.tags['priority_class']   AS priority_class,

  argMax(d.value, d.timestamp) AS value,
  max(d.timestamp)             AS ts
FROM timeSeriesData(metrics.ts) AS d
INNER JOIN timeSeriesTags(metrics.ts) AS t
  ON t.id = d.id
WHERE
  t.metric_name = 'beget_pod_info'
  AND d.timestamp >= toDateTime(1770506576) AND d.timestamp <= toDateTime(1770549776)
  AND t.tags['cluster']   IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['namespace'] IN ('apmistcs')
  AND t.tags['pod']       IN ('apmistcs-system-2-infra-cloud-controller-manager-8f45949d-2qldc')
GROUP BY
  cluster, namespace, pod, container, phase,
  created_by_kind, created_by_name,
  node, host_ip, pod_ip, host_network, priority_class
ORDER BY ts DESC;
```

### beget_pod_memory_usage_mb
#### Описание
Потребление RAM pod'ом
#### Лейблы
- cluster
- container
- namespace
- node
- pod
#### Значения
В ядрах
#### Как вычисляется в vmAlert
```
avg by (cluster, node, namespace, pod, container) (
  label_replace(
    container_memory_working_set_bytes{pod!="", namespace!=""},
    "cluster", "$1", "cluster_full_name", "(.*)"
  )
)  / 1024 / 1024
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 60 SECOND) AS time,
  concat(t.tags['namespace'], '/', t.tags['pod']) AS metric,
  avg(d.value) AS USAGES
FROM timeSeriesData(metrics.ts) d
JOIN timeSeriesTags(metrics.ts) t ON t.id = d.id
WHERE
  t.metric_name = 'beget_pod_memory_usage_mb'
  AND d.timestamp >= toDateTime(1770505465) AND d.timestamp <= toDateTime(1770548665)
  AND t.tags['cluster']   IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['namespace'] IN ('apmistcs')
  AND t.tags['pod']       IN ('apmistcs-system-2-infra-cloud-controller-manager-8f45949d-2qldc')
GROUP BY time, metric
ORDER BY time;
```

### beget_pod_cpu_usage_cores
#### Описание
Потребление CPU pod'ом
#### Лейблы
- cluster
- container
- namespace
- node
- pod
#### Значения
В ядрах
#### Как вычисляется в vmAlert
```
avg by (cluster, node, namespace, pod, container) (
  rate(
    label_replace(
      container_cpu_usage_seconds_total{pod!="", namespace!=""},
      "cluster", "$1", "cluster_full_name", "(.*)"
    )
  )
)
```
#### Пример запроса в Clikhouse
```
SELECT
  toStartOfInterval(d.timestamp, INTERVAL 30 SECOND) AS time,
  concat(t.tags['namespace'], '/', t.tags['pod']) AS metric,
  avg(d.value) AS USAGES
FROM timeSeriesData(metrics.ts) d
JOIN timeSeriesTags(metrics.ts) t ON t.id = d.id
WHERE
  t.metric_name = 'beget_pod_cpu_usage_cores'
  AND d.timestamp >= toDateTime(1770505402) AND d.timestamp <= toDateTime(1770548602)
  AND t.tags['cluster']   IN ('dlputim6-apmistcs-system-2-infra')
  AND t.tags['namespace'] IN ('apmistcs')
  AND t.tags['pod']       IN ('apmistcs-system-2-infra-cloud-controller-manager-8f45949d-2qldc')
GROUP BY time, metric
ORDER BY time;
```

## Рекомендации
1. В запросах требуется указывать временные промежутки и интервалы.
2. Интервал рекомендуется вычислять исходя из выбранного временного отрезка, чтобы на больших периодах не делать тяжелых запросов и не получать излишне много значений
