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
        spec:
          templates:
            - key: telegram_alerts.tmpl
              name: vmalertmanager-alertmanager-alert-templates
          serviceSpec:
            metadata:
              name: vmalertmanager
              labels:
                monitoring.in-cloud.io/service: vmalertmanager
            spec:
              ports:
                - name: http
                  port: 9093
                  protocol: TCP
                  targetPort: 9093
                - name: https-metrics
                  port: 11043
                  protocol: TCP
                  targetPort: https-metrics
          containers:
            - name: alertmanager
              volumeMounts:
                - name: alertmanager-tls
                  mountPath: /app/config/alertmanager/web/tls
                  readOnly: true
            - name: rbac-proxy
              image: quay.io/brancz/kube-rbac-proxy:v0.21.0
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
                secretName: vmalertmanager-monitoring-svc-tls
            - name: alertmanager-tls
              secret:
                defaultMode: 420
                secretName: {{ $clusterName }}-alertmanager
          podMetadata:
            labels:
              in-cloud-metrics: "infra"
          configSecret: vmalertmanager-config
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

    alertmanagerConfig:
      enabled: true
      config:
        global:
          resolve_timeout: 5m

        route:
          receiver: blackhole
          group_by: ["cluster_full_name", "alertname", "severity"]
          group_wait: 10s
          group_interval: 30s
          repeat_interval: 3h

          routes:
            blackhole:
              matchers:
                - alertname="Watchdog"
              receiver: blackhole
            telegram:
              matchers:
                - severity="critical"
              receiver: telegram-critical
              continue: true
            signalilo:
              matchers:
                - severity="critical"
              receiver: signalilo-critical
              continue: true

        receivers:
          blackhole: {}
          telegram-critical:
            type: telegram_configs
            configs:
              criticalAlertGroup:
                bot_token: "123456789:AAExampleTokenHere"
                chat_id: -1001234567890
                parse_mode: 'HTML'
                send_resolved: true
                message: '{{ template "tg.message" . }}'
          signalilo-critical:
            type: webhook_configs
            configs:
              mainSignaliloInstance:
                url: "http://signalilo.beget-signalilo.svc/webhook?token=HrVSzDOrZthErVJwxddMJHefHYkvr/XWVc1XGcazh1I="
                send_resolved: true

        inhibit_rules:
          - source_matchers:
              - alertname="BegetCapiClusterNotAlive"
            target_matchers:
              - alertname=~"ArgoCdClusterConnectionError|BegetCapiClusterNotReadyTooLong|VMAgentJobAbsent|VMAlertJobAbsent|VMAlertmanagerJobAbsent|VMAgentTooManyScrapePoolWithoutTargets|VMagentLogsErrorsHigh"
            equal:
              - cluster_full_name

          - source_matchers:
              - alertname="ArgoCdClusterConnectionError"
            target_matchers:
              - alertname=~"ArgoCdAppUnhealthy|ArgoCdAppOutOfSync|ArgoCdAppSyncFailed"
            equal:
              - cluster_full_name

          - source_matchers:
              - alertname="CoreDNSErrorsHighCritical"
            target_matchers:
              - alertname="CoreDNSErrorsHigh"
            equal:
              - cluster_full_name

          - source_matchers:
              - alertname="ExtremelyHighIndividualControlPlaneCPU"
            target_matchers:
              - alertname=~"HighIndividualControlPlaneCPU|HighOverallControlPlaneCPU"
            equal:
              - cluster_full_name

          - source_matchers:
              - alertname="BegetCapiClusterNotReadyTooLong"
            target_matchers:
              - alertname="BegetCapiClusterNotReady"
            equal:
              - cluster_full_name

          - source_matchers:
              - alertname="VMAgentTooManyScrapePoolWithoutTargets"
            target_matchers:
              - alertname="VMAgentScrapePoolHasNoTargets"
            equal:
              - cluster_full_name
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
  `}}
{{- end -}}
