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
  values:
    victoria-metrics-k8s-stack:
      vmcluster:
        spec:
          retentionPeriod: "1"
          replicationFactor: 2
          vmstorage:
            replicaCount: 2
            storageDataPath: /vm-data
            storage:
              emptyDir:
                sizeLimit: 1000Mi
            claimTemplates: []
            resources:
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
          vmselect:
            enabled: true
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
            cacheMountPath: "/select-cache"
            claimTemplates: []
            storage: {}
            resources:
              requests:
                cpu: "50m"
                memory: "64Mi"
            priorityClassName: system-node-critical
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
          vminsert:
            enabled: true
            priorityClassName: system-cluster-critical
            resources:
              requests:
                cpu: "50m"
                memory: "64Mi"
            extraArgs:
              maxLabelValueLen: "8192"
              maxLabelsPerTimeseries: "80"
              insert.maxQueueDuration: 60s
              maxConcurrentInserts: "256"
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
  ` }}
{{- end -}}