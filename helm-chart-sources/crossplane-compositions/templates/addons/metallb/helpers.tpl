{{- define "addons.metallb" }}
name: Metallb
debug: false
path: helm-chart-sources/metallb
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "metallb" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  metallb:
    controller:
      enabled: true
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      resources:
        limits:
          cpu: 150m
          memory: 150Mi
        requests:
          cpu: 10m
          memory: 10Mi
immutable: |
  metallb:
    speaker:
      enabled: false
      frr:
        enabled: false
{{- end }}
