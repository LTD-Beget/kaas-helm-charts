{{- define "coredns.phase.infra" }}
- name: infra
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.environment
      operator: Equal
      value: "infra"
  selector:
    name: infra
    priority: 15
    matchLabels:
      addons.in-cloud.io/values: infra
      addons.in-cloud.io/addon: coredns
{{- end }}