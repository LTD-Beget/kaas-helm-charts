{{- define "extra-resources.phase.rules.cluster-network-policies" -}}
- name: cluster-network-policies
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.environment
      operator: Equal
      value: "infra"
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: cilium{{ .Values.suffix }}
      jsonPath: $.status.phaseValuesSelector[?(@.name=='enforcement-always')]
      operator: Exists
      keep: false
  selector:
    name: cluster-network-policies
    priority: 68
    matchLabels:
      addons.in-cloud.io/values: cluster-network-policies
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
