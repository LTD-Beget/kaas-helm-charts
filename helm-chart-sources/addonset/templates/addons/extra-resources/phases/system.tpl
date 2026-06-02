{{- define "extra-resources.phase.rules.system" -}}
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
      keep: false
    - source:
        apiVersion: v1
        kind: Secret
        name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
      operator: Exists
  selector:
    name: system
    priority: 40
    matchLabels:
      addons.in-cloud.io/values: system
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
