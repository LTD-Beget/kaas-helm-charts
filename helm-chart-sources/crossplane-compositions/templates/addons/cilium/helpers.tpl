{{- define "addons.cilium" }}
name: Cilium
debug: false
path: helm-chart-sources/cilium
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/xclusterComponents
pluginName: kustomize-helm-with-values
default: |
  cilium:
    image:
      pullPolicy: IfNotPresent
    envoy:
      enabled: false
    hubble:
      enabled: false
    kubeProxyReplacement: true
    nodePort:
      enabled: true
    operator:
      replicas: 1
      image:
        pullPolicy: IfNotPresent
    myDefault: test1
    dnsPolicy: ClusterFirstWithHostNet
    prometheus:
      metricsService: true
      enabled: true
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
immutable: |
  cilium:
    k8sServiceHost: {{ "{{ .host }}" }}
    k8sServicePort: {{ "{{ .port }}" }}
manifest:
  spec:
    forProvider:
      manifest:
        spec:
          ignoreDifferences:
          - group: admissionregistration.k8s.io
            kind: Service
            jqPathExpressions:
              - .spec.ports[]?.nodePort
{{- end }}
