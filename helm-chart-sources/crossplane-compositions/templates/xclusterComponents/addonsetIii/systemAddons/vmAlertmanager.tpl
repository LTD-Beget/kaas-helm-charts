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
        config:
          global:
            resolve_timeout: 5m

          route:
            receiver: 'telegram'
            group_wait: 10s
            group_interval: 30s
            repeat_interval: 1h

            routes:
              - matchers:
                  - severity="critical"
                receiver: telegram-critical
                continue: true
              - matchers:
                  - alertname="Watchdog"
                receiver: blackhole

          receivers:
            - name: telegram-critical
              telegram_configs:
                - bot_token: '123456789:AAExampleTokenHere'
                  chat_id: -1001234567890
                  parse_mode: 'HTML'
                  send_resolved: true
                  message: '{{ template "tg.message" . }}'

        templateFiles:
          telegram_alerts.tmpl: |
            {{ define "emoji.status" -}}
            {{- if eq .Status "firing" -}}🚨{{- else -}}✅{{- end -}}
            {{- end }}

            {{ define "emoji.severity" -}}
            {{- $s := (index .CommonLabels "severity") -}}
            {{- if eq $s "critical" -}}🟥{{- else if eq $s "warning" -}}🟧{{- else if eq $s "info" -}}🟦{{- else -}}⬜{{- end -}}
            {{- end }}

            {{ define "title" -}}
            {{ template "emoji.status" . }} {{ template "emoji.severity" . }} <b>{{ .CommonLabels.alertname }}</b>
            {{- end }}

            {{ define "kv" -}}
            {{- range $k, $v := . -}}
            <b>{{ $k }}:</b> <code>{{ $v }}</code>
            {{ end -}}
            {{- end }}

            {{/* --- main message for Telegram --- */}}
            {{ define "tg.message" -}}
            {{ template "title" . }}

            <b>Status:</b> <code>{{ upper .Status }}</code>
            <b>Severity:</b> <code>{{ index .CommonLabels "severity" }}</code>
            {{- if (index .CommonLabels "cluster") }}
            <b>Cluster:</b> <code>{{ index .CommonLabels "cluster" }}</code>
            {{- end }}
            {{- if (index .CommonLabels "namespace") }}
            <b>Namespace:</b> <code>{{ index .CommonLabels "namespace" }}</code>
            {{- end }}
            {{- if (index .CommonLabels "service") }}
            <b>Service:</b> <code>{{ index .CommonLabels "service" }}</code>
            {{- end }}

            {{- if .CommonAnnotations.summary }}
            <b>Summary:</b> {{ .CommonAnnotations.summary }}
            {{- end }}
            {{- if .CommonAnnotations.description }}
            <b>Description:</b> {{ .CommonAnnotations.description }}
            {{- end }}
            {{- if .CommonAnnotations.runbook_url }}
            <b>Runbook:</b> {{ .CommonAnnotations.runbook_url }}
            {{- end }}
            {{- if .ExternalURL }}
            <b>Alertmanager:</b> {{ .ExternalURL }}
            {{- end }}

            <b>Alerts:</b> <code>{{ len .Alerts }}</code>
            {{ range .Alerts -}}
            —
            <b>Instance:</b> <code>{{ index .Labels "instance" }}</code>
            {{- if (index .Labels "pod") }} <b>Pod:</b> <code>{{ index .Labels "pod" }}</code>{{ end }}
            {{- if (index .Labels "node") }} <b>Node:</b> <code>{{ index .Labels "node" }}</code>{{ end }}
            {{- if .Annotations.summary }} 
            <b>•</b> {{ .Annotations.summary }}
            {{- end }}
            <b>StartsAt:</b> <code>{{ .StartsAt }}</code>
            {{- if ne $.Status "firing" }}
            <b>EndsAt:</b> <code>{{ .EndsAt }}</code>
            {{- end }}
            {{- if .GeneratorURL }}
            <b>Source:</b> {{ .GeneratorURL }}
            {{- end }}
            {{ end -}}
            {{- end }}
        spec:
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
                secretName: vmalertmanager-monitoring-svc-tls
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
