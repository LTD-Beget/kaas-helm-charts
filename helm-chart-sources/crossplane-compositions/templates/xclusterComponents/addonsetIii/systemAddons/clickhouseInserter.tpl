{{- define "xclusterComponents.addonsetIii.clickhouseInserter" -}}
  {{- printf `
clickhouseInserter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsClickhouseInserter
  namespace: beget-clickhouse-vmstorage
  version: v1alpha1
  releaseName: clickhouse-inserter
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-k8s-stack:
      fullnameOverride: clickhouse-inserter
      clickhouseIserter:
        enabled: true
      vmalert:
        spec:
          extraArgs:
            'notifier.blackhole': "true"
          containers:
            - name: rbac-proxy
              image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
              args:
                - --secure-listen-address=0.0.0.0:11043
                - --upstream=http://127.0.0.1:8080
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
                - mountPath: /etc/ssl/certs
                  name: trusted-ca-certs
                  readOnly: true
          volumes:
            - name: rbac-proxy-tls
              secret:
                defaultMode: 420
                secretName: vmalert-monitoring-svc-tls
            - name: trusted-ca-certs
              configMap:
                name: ca
          tolerations:
            - key: "node-role.kubernetes.io/control-plane"
              operator: "Exists"
              effect: "NoSchedule"
            - key: "node-role.kubernetes.io/master"
              operator: "Exists"
              effect: "NoSchedule"
          externalLabels:
            in-cloud-metrics: "clickhouse"
          podMetadata:
            labels:
              in-cloud-metrics: "clickhouse"
          evaluationInterval: 60s
          selectAllByDefault: false
          ruleNamespaceSelector: {}
          ruleSelector:
            matchLabels:
              in-cloud-metrics: "clickhouse"
          resources:
            limits:
              cpu: 1
              memory: 1Gi
            requests:
              cpu: 100m
              memory: 128Mi
          replicaCount: 1
          updateStrategy: RollingUpdate
          extraEnvs:
            - name: GOMAXPROCS
              value: "4"
          remoteWrite:
            url: "http://clickhouse-vmstorage.beget-clickhouse-vmstorage.svc:9363/promrw"
            concurrency: 4
            basicAuth:
              username:
                name: clickhouse-credentials
                key: username
              password:
                name: clickhouse-credentials
                key: password
          remoteRead:
            url: "https://vmselect.beget-vmcluster.svc:8481/select/0/prometheus"
            tlsConfig:
              ca:
                configMap:
                  name: ca
                  key: ca.crt
          datasource:
            url: "https://vmselect.beget-vmcluster.svc:8481/select/0/prometheus"
            tlsConfig:
              ca:
                configMap:
                  name: ca
                  key: ca.crt
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
