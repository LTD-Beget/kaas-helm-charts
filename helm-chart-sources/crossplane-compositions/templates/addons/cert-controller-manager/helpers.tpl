{{- define "addons.certcontrollermanager" }}
name: CertControllerManager
debug: false
path: dist/chart
repoURL: https://github.com/PRO-Robotech/certificate-set

{{- $addonValue := dig "composite" "addons" "certcontrollermanager" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
pluginName: helm-with-values
default: |
  manager:
    args:
    - --cluster-wide
    image:
      repository: prorobotech/certificate-set
      tag: main-3a388eb6
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
