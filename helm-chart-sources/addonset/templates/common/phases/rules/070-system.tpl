{{- define "common.phase.rules.system" }}
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
    priority: 70
    matchLabels:
      addons.in-cloud.io/values: system
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
