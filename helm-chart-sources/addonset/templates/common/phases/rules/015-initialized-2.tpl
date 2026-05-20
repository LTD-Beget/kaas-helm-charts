{{- define "common.phase.rules.initialized-2" -}}
- name: initialized-2
  criteria:
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: {{ .Values.addonName }}{{ .Values.suffix }}
      jsonPath: $.status.phaseValuesSelector[?(@.name=='initialized')]
      operator: Equal
      value: true
      keep: false
  selector:
    name: initialized-2
    priority: 15
    matchLabels:
      addons.in-cloud.io/values: initialized-2
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
