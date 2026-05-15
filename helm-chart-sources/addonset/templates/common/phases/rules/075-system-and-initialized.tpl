{{- define "common.phase.rules.system-and-initialized" }}
- name: system-and-initialized
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: parameters{{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.systemEnabled
      operator: Equal
      value: "true"
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: {{ .Values.addonName }}{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
  selector:
    name: system-and-initialized
    priority: 75
    matchLabels:
      addons.in-cloud.io/values: system-and-initialized
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
