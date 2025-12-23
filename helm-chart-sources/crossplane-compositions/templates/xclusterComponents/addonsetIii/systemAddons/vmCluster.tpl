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
              - key: "dedicated"
                value: "monitoring"
                effect: "NoSchedule"
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                    - matchExpressions:
                        - key: node-role.kubernetes.io/monitoring
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
              - key: "dedicated"
                value: "monitoring"
                effect: "NoSchedule"
              - key: "dedicated"
                value: "vminsert"
                effect: "NoSchedule"
            volumes:
              - name: vmselect-tls
                secret:
                  secretName: {{ $clusterName }}-vmselect
            volumeMounts:
              - name: vmselect-tls
                mountPath: /tls
                readOnly: true
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                    - matchExpressions:
                        - key: node-role.kubernetes.io/monitoring
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
              - key: "dedicated"
                value: "monitoring"
                effect: "NoSchedule"
              - key: "dedicated"
                value: "vminsert"
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
                annotations:
                  lb.beget.com/algorithm: "round_robin"
                  lb.beget.com/type: "internal"
                  lb.beget.com/healthcheck-interval-seconds: "60"
                  lb.beget.com/healthcheck-timeout-seconds: "5"
              spec:
                type: LoadBalancer
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                    - matchExpressions:
                        - key: node-role.kubernetes.io/vminsert
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
          app: "vminsert"
        selector:
          app.kubernetes.io/name: "vminsert"
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
          url: "https://vmselect-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc:8481/select/0/prometheus"
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
            - "vminsert-vmcluster-victoria-metrics-k8s-stack"
            - "vminsert-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster"
            - "vminsert-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc"
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
            - "vmselect-vmcluster-victoria-metrics-k8s-stack"
            - "vmselect-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster"
            - "vmselect-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc"
          ipAddresses:
            - 127.0.0.1
  ` }}
{{- end -}}
