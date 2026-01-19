{{- define "addons.secretcopyoperator" }}
name: SecretCopyOperator
debug: false
path: dist/chart
repoURL: https://github.com/PRO-Robotech/secret-copy-operator

{{- $addonValue := dig "composite" "addons" "secretcopyoperator" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
default: |
  manager:
    image:
      repository: prorobotech/secret-copy-operator
      tag: feature-CLOUD-409-3ba098a4
      pullPolicy: IfNotPresent
    tolerations:
    - effect: NoExecute
      operator: Exists
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
{{- end }}
