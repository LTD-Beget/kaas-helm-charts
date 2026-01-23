{{- define "xclusterComponents.addonsetIii.vmAlertmanager" -}}
  {{- printf `
vmAlertmanager:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAlertmanager
  namespace: beget-alertmanager
  version: v1alpha1
  releaseName: vmalertmanager
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-k8s-stack:
      fullnameOverride: "alertmanager"
      alertmanager:
        useManagedConfig: false
        config:
          global:
            resolve_timeout: 5m
            http_config:
              follow_redirects: true
              enable_http2: true
          route:
            receiver: signalilo
            group_by: ["alertname", "namespace", "severity"]
            group_wait: 30s
            group_interval: 5m
            repeat_interval: 1h

            routes:
              - matchers:
                  - severity=~"info|warning|critical"
                receiver: signalilo
              - receiver: blackhole
                matchers:
                  - alertname="Watchdog"
                continue: false

          receivers:
            - name: signalilo
              webhook_configs:
                - url: "http://signalilo.beget-signalilo.svc/webhook?token=HrVSzDOrZthErVJwxddMJHefHYkvr/XWVc1XGcazh1I="
                  send_resolved: true
            - name: blackhole

          templates:
            - /etc/vm/configs/**/*.tmpl
            - /etc/vm/templates/vmalertmanager-alertmanager-monzo-tpl/monzo.tmpl

        spec:
          # serviceScrapeSpec:
          #   selector:
          #     matchLabels:
          #       monitoring.in-cloud.io/service: alertmanager
          #   endpoints:
          #     - port: https-metrics
          #       path: /metrics
          #       scheme: HTTPS
          #       bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
          #       tlsConfig:
          #         serverName: alertmanager-monitoring
          #   jobLabel: alertmanager
          containers:
            - name: alertmanager
              volumeMounts:
                - name: alertmanager-tls
                  mountPath: /app/config/alertmanager/web/tls
                  readOnly: true
            - name: rbac-proxy
              image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
              args:
                - --secure-listen-address=0.0.0.0:11043
                - --upstream=https://127.0.0.1:9093
                - --upstream-ca-file=/app/config/alertmanager/web/tls/ca.crt
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
                - name: alertmanager-tls
                  mountPath: /app/config/alertmanager/web/tls
                  readOnly: true
          volumes:
            - name: rbac-proxy-tls
              secret:
                defaultMode: 420
                secretName: alertmanager-monitoring-svc-tls
            - name: alertmanager-tls
              secret:
                defaultMode: 420
                secretName: {{ $clusterName }}-alertmanager
          podMetadata:
            labels:
              in-cloud-metrics: "infra"
          configSelector:
            matchLabels:
              in-cloud-metrics: "infra"
          tolerations:
            - key: "node-role.kubernetes.io/control-plane"
              operator: "Exists"
              effect: "NoSchedule"
            - key: "node-role.kubernetes.io/master"
              operator: "Exists"
              effect: "NoSchedule"
          webConfig:
            tls_server_config:
              cert_file: "/app/config/alertmanager/web/tls/tls.crt"
              key_file: "/app/config/alertmanager/web/tls/tls.key"
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
    tls:
      alertmanager:
        enabled: true
        issuer:
          kind: ClusterIssuer
          name: selfsigned-cluster-issuer
        certificate:
          name: {{ $clusterName }}-alertmanager
          secretName: {{ $clusterName }}-alertmanager
          commonName: alertmanager
          dnsNames:
            - "vmalertmanager-alertmanager"
            - "vmalertmanager-alertmanager.beget-alertmanager"
            - "vmalertmanager-alertmanager.beget-alertmanager.svc"
          ipAddresses:
            - 127.0.0.1
  ` }}
{{- end -}}
