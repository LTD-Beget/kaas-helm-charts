{{- define "common.phase.rules.60-system" }}
- name: system
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.systemEnabled
      operator: Equal
      value: "true"
  selector:
    name: system
    priority: 60
    matchLabels:
      addons.in-cloud.io/values: system
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}