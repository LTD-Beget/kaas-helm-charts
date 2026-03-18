{{- define "xclusterComponents.addonsetIii.prometheusNodeExporter" -}}
  {{- printf `
prometheusNodeExporter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsPrometheusNodeExporter
  namespace: beget-prometheus-node-exporter
  version: v1alpha1
  dependsOn:
    - vmOperator
  pluginName: helm-with-values
  values:
    prometheus-node-exporter:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      {{ if $systemEnabled }}
        - key: "node-role.kubernetes.io/argocd"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/crossplane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/vm-stream"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/vm-data"
          operator: "Exists"
          effect: "NoSchedule"
      {{ end }}
    {{ if $certManagerReady }}
      service:
        labels:
          monitoring.in-cloud.io/service: prometheus-node-exporter
        portName: https-metrics
      kubeRBACProxy:
        enabled: true
        image:
          registry: quay.io
          repository: brancz/kube-rbac-proxy
          tag: v0.21.0

        extraArgs:
          - --secure-listen-address=0.0.0.0:9100
          - --upstream=http://127.0.0.1:8100
          - --tls-cert-file=/app/config/metrics/tls/tls.crt
          - --tls-private-key-file=/app/config/metrics/tls/tls.key
          - --v=2

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

      volumes:
        - name: rbac-proxy-tls
          secret:
            defaultMode: 420
            secretName: kube-state-metrics-svc-tls
    {{ end }}
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
