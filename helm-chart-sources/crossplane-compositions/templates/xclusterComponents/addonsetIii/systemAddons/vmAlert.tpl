{{- define "xclusterComponents.addonsetIii.vmAlert" -}}
  {{- printf `
vmAlert:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAlert
  namespace: beget-vmalert
  version: v1alpha1
  releaseName: vmalert
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-k8s-stack:
      vmalert:
        spec:
          serviceScrapeSpec:
            selector:
              matchLabels:
                monitoring.in-cloud.io/service: vmalert
            endpoints:
              - port: https-metrics
                path: /metrics
                scheme: HTTPS
                bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
                tlsConfig:
                  serverName: vmalert-monitoring
            jobLabel: vmalert
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
            in-cloud-metrics: "infra"
          podMetadata:
            labels:
              in-cloud-metrics: "infra"
          evaluationInterval: 60s
          selectAllByDefault: false
          ruleNamespaceSelector: {}
          ruleSelector:
            matchLabels:
              in-cloud-metrics: "infra"
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
            url: "https://vminsert-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc:8480/insert/0/prometheus/api/v1/write"
            concurrency: 4
            tlsConfig:
              caFile: /etc/ssl/certs/ca.crt
          remoteRead:
            url: "http://vmselect-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc:8481/select/0/prometheus"
          datasource:
            url: "http://vmselect-vmcluster-victoria-metrics-k8s-stack.beget-vmcluster.svc:8481/select/0/prometheus"
          notifiers:
            - url: "http://vmalertmanager-alertmanager.beget-alertmanager.svc:9093"
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
