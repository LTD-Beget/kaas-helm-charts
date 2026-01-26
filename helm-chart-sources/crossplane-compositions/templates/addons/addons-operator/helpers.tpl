{{- define "addons.addonsoperator" }}
name: AddonsOperator
debug: false
path: dist/chart
repoURL: https://github.com/PRO-Robotech/addons-operator

{{- $addonValue := dig "composite" "addons" "addonsoperator" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
default: |
  manager:
    args:
    - --cluster-wide
    image:
      repository: prorobotech/addons-operator
      tag: v0.1.0-a90bf6c5
      pullPolicy: IfNotPresent
    tolerations:
    - effect: NoExecute
      operator: Exists
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
  metrics:
    enable: true
    port: 8443
{{- end }}
