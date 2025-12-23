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
          serviceScrapeSpec:
            selector:
              matchLabels:
                monitoring.in-cloud.io/service: alertmanager
            endpoints:
              - port: https-metrics
                path: /metrics
                scheme: HTTPS
                bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
                tlsConfig:
                  serverName: alertmanager-monitoring
            jobLabel: alertmanager
          containers:
            - name: rbac-proxy
              image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
              args:
                - --secure-listen-address=0.0.0.0:11043
                - --upstream=http://127.0.0.1:9093
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
          volumes:
            - name: rbac-proxy-tls
              secret:
                defaultMode: 420
                secretName: alertmanager-monitoring-svc-tls
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
              cert_secret_ref:
                name: "{{ $clusterName }}-alertmanager"
                key: tls.crt
              key_secret_ref:
                name: "{{ $clusterName }}-alertmanager"
                key: tls.key
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
            - "vmalertmanager-alertmanager.beget-vmcluster"
            - "vmalertmanager-alertmanager.beget-vmcluster.svc"
          ipAddresses:
            - 127.0.0.1
  ` }}
{{- end -}}
