{{- define "addons.certmanager" }}
name: CertManager
debug: false
path: helm-chart-sources/certmanager
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "certmanager" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: kustomize-helm-with-values
default: |
  cert-manager:
    global:
      priorityClassName: system-cluster-critical
    cainjector:
      containerSecurityContext:
        runAsNonRoot: true
      resources:
        limits:
          cpu: 250m
          memory: 256Mi
        requests:
          cpu: 50m
          memory: 128Mi
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    containerSecurityContext:
      runAsNonRoot: true
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
    startupapicheck:
      containerSecurityContext:
        runAsNonRoot: true
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    webhook:
      containerSecurityContext:
        runAsNonRoot: true
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 50m
          memory: 128Mi
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
immutable: |
  cert-manager:
    installCRDs: true
    enableCertificateOwnerRef: true

{{- end }}
