{{- define "common.phase.rules.initialized" }}
- name: initialized
  criteria:
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: {{ .Values.addonName }}{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
  selector:
    name: initialized
    priority: 10
    matchLabels:
      addons.in-cloud.io/values: initialized
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
