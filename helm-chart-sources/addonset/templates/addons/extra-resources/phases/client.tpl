{{- define "extra-resources.phase.rules.client" -}}
- name: client
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.systemEnabled
      operator: Equal
      value: "false"
      keep: false
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.environment
      operator: Equal
      value: "client"
      keep: false
    - source:
        apiVersion: v1
        kind: Secret
        name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
      operator: Exists
  selector:
    name: client
    priority: 20
    matchLabels:
      addons.in-cloud.io/values: client
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
