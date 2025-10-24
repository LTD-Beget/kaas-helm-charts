{{- define "xclusterComponents.addonsetIii.vmAgent" -}}
  {{- printf `
vmAgent:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAgent
  namespace: beget-vmagent
  version: v1alpha1
  releaseName: vmagent
  values:
    fullnameOverride: "vmagent"
    vmagent:
      spec:
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
        podMetadata:
          labels:
            app: vmagent
            incloud-metrics: "infra"
        remoteWrite:
          - url: http://prometheus-server.beget-prometheus.svc:80/api/v1/write
        serviceScrapeNamespaceSelector:
          matchExpressions:
            - operator: In
              key: "in-cloud.io/clusterName"
              values: [{{ $clusterName }}]
        podScrapeNamespaceSelector:
          matchExpressions:
            - operator: In
              key: "in-cloud.io/clusterName"
              values: [{{ $clusterName }}]
        nodeScrapeNamespaceSelector:
          matchExpressions:
            - operator: In
              key: "in-cloud.io/clusterName"
              values: [{{ $clusterName }}]
        staticScrapeNamespaceSelector:
          matchExpressions:
            - operator: In
              key: "in-cloud.io/clusterName"
              values: [{{ $clusterName }}]
        probeNamespaceSelector:
          matchExpressions:
            - operator: In
              key: "incloud.io/clusterName"
              values: [{{ $clusterName }}]
        externalLabels:
          cluster_full_name: {{ printf "%%s-%%s" $customer $clusterName }}
          remotewrite_cluster: {{ printf "%%s-%%s" $customer $clusterName }}
        extraArgs:
          remoteWrite.label: remotewrite_cluster={{ printf "%%s-%%s" $customer $clusterName }}
    kubeControllerManager:
      enabled: true
      vmScrape:
        spec:
          endpoints:
            - port: "http-metrics"
              scheme: "https"
              bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
              tlsConfig:
                caFile: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                serverName: {{ printf "%%s-controller-manager" $clusterName }}
    kubeScheduler:
      enabled: true
      vmScrape:
        spec:
          endpoints:
            - port: "http-metrics"
              scheme: "https"
              bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
              tlsConfig:
                caFile: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                serverName: {{ printf "%%s-scheduler" $clusterName }}
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{ end }}
  ` }}
{{- end -}}