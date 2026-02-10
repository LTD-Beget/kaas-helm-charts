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
            containers:
              - name: rbac-proxy
                image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
                args:
                  - --secure-listen-address=0.0.0.0:11043
                  - --upstream=http://127.0.0.1:8482
                  - --tls-cert-file=/app/config/metrics/tls/tls.crt
                  - --tls-private-key-file=/app/config/metrics/tls/tls.key
                  - --v=2
                ports:
                  - name: https-metrics
                    containerPort: 11043
                    protocol: TCP
                resources:
                  requests:
                    memory: "32Mi"
                    cpu: "10m"
                  limits:
                    memory: "64Mi"
                    cpu: "50m"
                volumeMounts:
                  - name: rbac-proxy-tls
                    mountPath: /app/config/metrics/tls
                    readOnly: true
                  - mountPath: /etc/ssl/certs/ca.crt
                    subPath: ca.crt
                    name: trusted-ca-certs
                    readOnly: true
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
            volumes:
              - name: rbac-proxy-tls
                secret:
                  defaultMode: 420
                  secretName: vmcluster-monitoring-svc-tls
              - name: trusted-ca-certs
                configMap:
                  name: ca
            serviceSpec:
              metadata:
                name: vmstorage
                labels:
                  monitoring.in-cloud.io/service: vmstorage
              spec:
                type: ClusterIP
                ports:
                  - name: http
                    port: 8482
                    protocol: TCP
                    targetPort: 8482
                  - name: https-metrics
                    port: 11043
                    protocol: TCP
                    targetPort: https-metrics
                useAsDefault: true
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
            containers:
              - name: rbac-proxy
                image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
                args:
                  - --secure-listen-address=0.0.0.0:11043
                  - --upstream=https://127.0.0.1:8481
                  - --upstream-ca-file=/app/config/vmselect/tls/ca.crt
                  - --tls-cert-file=/app/config/metrics/tls/tls.crt
                  - --tls-private-key-file=/app/config/metrics/tls/tls.key
                  - --v=2
                ports:
                  - name: https-metrics
                    containerPort: 11043
                    protocol: TCP
                resources:
                  requests:
                    memory: "32Mi"
                    cpu: "10m"
                  limits:
                    memory: "64Mi"
                    cpu: "50m"
                volumeMounts:
                  - name: rbac-proxy-tls
                    mountPath: /app/config/metrics/tls
                    readOnly: true
                  - mountPath: /etc/ssl/certs/ca.crt
                    subPath: ca.crt
                    name: trusted-ca-certs
                    readOnly: true
                  - name: vmselect-tls
                    mountPath: /app/config/vmselect/tls
                    readOnly: true
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
              - name: rbac-proxy-tls
                secret:
                  defaultMode: 420
                  secretName: vmcluster-monitoring-svc-tls
              - name: trusted-ca-certs
                configMap:
                  name: ca
            volumeMounts:
              - name: vmselect-tls
                mountPath: /tls
                readOnly: true
            serviceSpec:
              metadata:
                name: vmselect
                labels:
                  monitoring.in-cloud.io/service: vmselect
              spec:
                type: ClusterIP
                ports:
                  - name: http
                    port: 8481
                    protocol: TCP
                    targetPort: 8481
                  - name: https-metrics
                    port: 11043
                    protocol: TCP
                    targetPort: https-metrics
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
            containers:
              - name: rbac-proxy
                image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
                args:
                  - --secure-listen-address=0.0.0.0:11043
                  - --upstream=https://127.0.0.1:8480
                  - --upstream-ca-file=/app/config/vminsert/tls/ca.crt
                  - --tls-cert-file=/app/config/metrics/tls/tls.crt
                  - --tls-private-key-file=/app/config/metrics/tls/tls.key
                  - --v=2
                ports:
                  - name: https-metrics
                    containerPort: 11043
                    protocol: TCP
                resources:
                  requests:
                    memory: "32Mi"
                    cpu: "10m"
                  limits:
                    memory: "64Mi"
                    cpu: "50m"
                volumeMounts:
                  - name: rbac-proxy-tls
                    mountPath: /app/config/metrics/tls
                    readOnly: true
                  - mountPath: /etc/ssl/certs/ca.crt
                    subPath: ca.crt
                    name: trusted-ca-certs
                    readOnly: true
                  - name: vmselect-tls
                    mountPath: /app/config/vminsert/tls
                    readOnly: true
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
                  secretName: vminsert-tls
              - name: rbac-proxy-tls
                secret:
                  defaultMode: 420
                  secretName: vmcluster-monitoring-svc-tls
              - name: trusted-ca-certs
                configMap:
                  name: ca
            volumeMounts:
              - name: vminsert-tls
                mountPath: /tls
                readOnly: true
            serviceSpec:
              metadata:
                name: vminsert
                labels:
                  monitoring.in-cloud.io/service: vminsert
                # annotations:
                #   lb.beget.com/algorithm: "round_robin"
                #   lb.beget.com/type: "internal"
                #   lb.beget.com/healthcheck-interval-seconds: "60"
                #   lb.beget.com/healthcheck-timeout-seconds: "5"
              spec:
                type: ClusterIP
                ports:
                  - name: http
                    port: 8480
                    protocol: TCP
                    targetPort: 8480
                  - name: https-metrics
                    port: 11043
                    protocol: TCP
                    targetPort: https-metrics
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
          app: vminsert
        selector:
          app.kubernetes.io/name: vminsert
    monitoring:
      enabled: true
      namespace: beget-prometheus
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
    tls:
      vmInsert:
        enabled: true
        issuer:
          kind: ClusterIssuer
          name: selfsigned-cluster-issuer
        certificate:
          name: vminsert-tls
          secretName: vminsert-tls
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
  ` }}
{{- end -}}
