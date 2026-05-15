{{- define "common.phase.rules.signalilo" }}
- name: signalilo
  criteria:
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: signalilo{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: signalilo{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
  selector:
    name: signalilo
    priority: 50
    matchLabels:
      addons.in-cloud.io/values: signalilo
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
