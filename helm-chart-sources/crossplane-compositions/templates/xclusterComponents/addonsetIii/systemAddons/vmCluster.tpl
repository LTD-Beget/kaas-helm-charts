{{- define "xclusterComponents.addonsetIii.vmCluster" -}}
  {{- printf `
vmCluster:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsCluster
  namespace: beget-vmcluster
  version: v1alpha1
  releaseName: vmcluster
  dependsOn:
    - vmOperator
    - grafanaOperator
  values:
    victoria-metrics-k8s-stack:
      vmcluster:
        spec:
          clusterDomainName: cluster.local
          retentionPeriod: "1"
          replicationFactor: 2
          vmstorage:
            replicaCount: 3
            storageDataPath: /vm-data
            claimTemplates: []
            storage:
              emptyDir:
                sizeLimit: 210Gi
              volumeClaimTemplate: {}
            resources:
              limits:
                cpu: "5"
              requests:
                cpu: "50m"
                memory: "64Mi"
            #TODO change hostpath
            tolerations:
              - key: "node-role.kubernetes.io/vm-data"
                operator: "Exists"
                effect: "NoSchedule"
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                    - matchExpressions:
                        - key: node-role.kubernetes.io/vm-data
                          operator: Exists
              podAntiAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  - labelSelector:
                      matchExpressions:
                        - key: app.kubernetes.io/name
                          operator: In
                          values:
                            - vmstorage
                    topologyKey: kubernetes.io/hostname
          vmselect:
            enabled: true
            replicaCount: 3
            extraArgs:
              dedup.minScrapeInterval: 30s
              search.maxQueryDuration: 60s
              search.maxQueryLen: "20971520"
              search.maxSeries: "300000000"
              search.maxSamplesPerQuery: "2000000000"
              search.maxSamplesPerSeries: "2000000000"
              search.maxUniqueTimeseries: "300000000"
              search.maxSeriesPerAggrFunc: "600000000"
              search.maxConcurrentRequests: "128"
              search.maxLabelsAPIDuration: 60s
              search.logSlowQueryDuration: 60s
              tls: "true"
              tlsCertFile: "/tls/tls.crt"
              tlsKeyFile: "/tls/tls.key"
            cacheMountPath: "/select-cache"
            claimTemplates: []
            storage:
              emptyDir:
                sizeLimit: 20Gi
              volumeClaimTemplate: {}
            resources:
              limits:
                cpu: "5"
                memory: "10Gi"
              requests:
                cpu: "50m"
                memory: "64Mi"
            priorityClassName: system-node-critical
            tolerations:
              - key: "node-role.kubernetes.io/vm-stream"
                operator: "Exists"
                effect: "NoSchedule"
            volumes:
              - name: vmselect-tls
                secret:
                  secretName: {{ $clusterName }}-vmselect
            volumeMounts:
              - name: vmselect-tls
                mountPath: /tls
                readOnly: true
            serviceSpec:
              metadata:
                name: vmselect
              spec:
                type: ClusterIP
                useAsDefault: true
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                    - matchExpressions:
                        - key: node-role.kubernetes.io/vm-stream
                          operator: Exists
              podAntiAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  - labelSelector:
                      matchExpressions:
                        - key: app.kubernetes.io/name
                          operator: In
                          values:
                            - vmselect
                    topologyKey: kubernetes.io/hostname
          vminsert:
            enabled: true
            replicaCount: 3
            rollingUpdate:
              maxSurge: 0
              maxUnavailable: 1
            priorityClassName: system-cluster-critical
            resources:
              limits:
                cpu: "4"
              requests:
                cpu: "50m"
                memory: "64Mi"
            extraArgs:
              maxLabelValueLen: "8192"
              maxLabelsPerTimeseries: "80"
              insert.maxQueueDuration: 60s
              maxConcurrentInserts: "256"
              tls: "true"
              tlsCertFile: "/tls/tls.crt"
              tlsKeyFile: "/tls/tls.key"
            tolerations:
              - key: "node-role.kubernetes.io/vm-stream"
                operator: "Exists"
                effect: "NoSchedule"   
            volumes:
              - name: vminsert-tls
                secret:
                  secretName: {{ $clusterName }}-vminsert
            volumeMounts:
              - name: vminsert-tls
                mountPath: /tls
                readOnly: true
            serviceSpec:
              metadata:
                name: vminsert
                # annotations:
                #   lb.beget.com/algorithm: "round_robin"
                #   lb.beget.com/type: "internal"
                #   lb.beget.com/healthcheck-interval-seconds: "60"
                #   lb.beget.com/healthcheck-timeout-seconds: "5"
              spec:
                type: ClusterIP # LoadBalancer
                useAsDefault: true
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                    - matchExpressions:
                        - key: node-role.kubernetes.io/vm-stream
                          operator: Exists
              podAntiAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  - labelSelector:
                      matchExpressions:
                        - key: app.kubernetes.io/name
                          operator: In
                          values:
                            - vminsert
                    topologyKey: kubernetes.io/hostname

      vmagent:
        enabled: true
        spec:
          selectAllByDefault: false
          containers:
            - name: config-reloader
              requests:
                cpu: 100m
                memory: 128Mi
              limits:
                cpu: 100m
                memory: 200Mi
              securityContext:
                runAsNonRoot: true
                runAsUser: 65534
            - name: vmagent
              securityContext:
                readOnlyRootFilesystem: true
                allowPrivilegeEscalation: false
          tolerations:
            - key: "node-role.kubernetes.io/control-plane"
              operator: "Exists"
              effect: "NoSchedule"
            - key: "node-role.kubernetes.io/master"
              operator: "Exists"
              effect: "NoSchedule"
          podMetadata:
            labels:
              app: vmagent-gateway
              incloud-metrics: "infra"
          remoteWrite:
            # Отправка сырых данных в vmcluster
            - url: https://vminsert.beget-vmcluster.svc:8480/insert/0/prometheus
              tlsConfig:
                caFile: /etc/ssl/certs/ca.crt
            # Отправка агрегированных данных в clickhouse
            # TODO: Добавить поддержку https
            - url: http://clickhouse-vmstorage-carbon.beget-clickhouse-vmstorage.svc:2006/api/v1/write
              streamAggrConfig:
                keepInput: false
                dropInput: true

                # Исключение лишних лейблов
                dropInputLabels: ["pod_uid", "container_id", "id", "image_id"]

                rules:
                  # Nodes: CPU
                  - match: 'node_cpu_seconds_total{mode="idle"}'
                    interval: 1m
                    by: ["cluster", "node"] # add nodegroup label
                    outputs: ["rate_avg"]   # streaming aggregation outputs https://docs.victoriametrics.com/victoriametrics/stream-aggregation/configuration/

                  # Nodes: RAM (достаточно MemAvailable и MemTotal)
                  - match: 'node_memory_MemAvailable_bytes'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["avg"]

                  - match: 'node_memory_MemTotal_bytes'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["last"]

                  # Nodes: Disk (size/available)
                  - match: 'node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["avg"]

                  - match: 'node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["last"]

                  # Pods: CPU/RAM per pod
                  - match: 'container_cpu_usage_seconds_total{container!="",image!=""}'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "node"]
                    outputs: ["rate_sum"]

                  - match: 'container_memory_working_set_bytes{container!="",image!=""}'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "node"]
                    outputs: ["avg"]

                  # Pods: restarts/status (kube-state-metrics)
                  - match: 'kube_pod_container_status_restarts_total'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "container"]
                    outputs: ["last"]

                  # статус по фазам (Running/Pending/Failed/...)
                  - match: 'kube_pod_status_phase'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "phase"]
                    outputs: ["last"]

                  - match: 'kube_pod_info'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "node"]
                    outputs: ["last"]
          volumeMounts:
            - name: trusted-ca-certs
              mountPath: /tls/cabundle
              readOnly: true
            - name: trusted-ca-certs
              mountPath: /etc/ssl/certs
              readOnly: true
          volumes:
            - name: trusted-ca-certs
              configMap:
                name: ca

    additionalService:
      # TODO: Стоит переделать на spec.[vminsert|vmselect|vmstorage].serviceSpec
      vmcluster:
        enabled: true
        name: vminsert-lb
        annotations:
          lb.beget.com/algorithm: "round_robin"
          lb.beget.com/type: "internal"
          lb.beget.com/healthcheck-interval-seconds: "60"
          lb.beget.com/healthcheck-timeout-seconds: "5"
        labels:
          app: "vmagent-gateway"
        selector:
          app.kubernetes.io/name: "vmagent-gateway"
    monitoring:
      enabled: false
      namespace: beget-prometheus
      grafana:
        vmDatasource:
          enabled: true
          name: {{ printf "victoriametrics-%%s" $clusterName }}
          namespace: beget-grafana
          selector: grafana
          type: prometheus
          isDefault: true
          url: "https://vmselect.beget-vmcluster.svc:8481/select/0/prometheus"
          jsonData:
            timeInterval: 5s
    tls:
      vmInsert:
        enabled: true
        issuer:
          kind: ClusterIssuer
          name: selfsigned-cluster-issuer
        certificate:
          name: {{ $clusterName }}-vminsert
          secretName: {{ $clusterName }}-vminsert
          commonName: vminsert
          dnsNames:
            - "vminsert"
            - "vminsert.beget-vmcluster"
            - "vminsert.beget-vmcluster.svc"
          ipAddresses:
            - 127.0.0.1
            - {{ $systemVmInsertVip }}
      vmSelect:
        enabled: true
        issuer:
          kind: ClusterIssuer
          name: selfsigned-cluster-issuer
        certificate:
          name: {{ $clusterName }}-vmselect
          secretName: {{ $clusterName }}-vmselect
          commonName: vmselect
          dnsNames:
            - "vmselect"
            - "vmselect.beget-vmcluster"
            - "vmselect.beget-vmcluster.svc"
          ipAddresses:
            - 127.0.0.1
  ` }}
{{- end -}}
