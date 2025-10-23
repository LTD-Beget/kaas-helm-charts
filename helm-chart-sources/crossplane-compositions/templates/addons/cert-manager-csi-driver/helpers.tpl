{{- define "addons.certmanagercsidriver" }}
name: CertManagerCsiDriver
debug: false
path: helm-chart-sources/certmanager-csi-driver
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
pluginName: kustomize-helm-with-values
default: |
  cert-manager-csi-driver:
    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
    resources:
      limits:
        cpu: 200m
        memory: 256Mi
      requests:
        cpu: 100m
        memory: 128Mi

{{- end }}
