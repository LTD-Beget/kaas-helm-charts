{{- define "common.phase.rules.client" -}}
- name: client
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.environment
      operator: Equal
      value: "client"
  selector:
    name: client
    priority: 20
    matchLabels:
      addons.in-cloud.io/values: client
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
