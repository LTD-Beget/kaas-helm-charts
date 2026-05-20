{{- define "common.phase.rules.cert-manager" -}}
- name: cert-manager
  criteria:
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: cert-manager{{ .Values.suffix }}
      jsonPath: $.status.phaseValuesSelector[?(@.name=='initialized-2')]
      operator: Exists
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: cert-manager{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
  selector:
    name: cert-manager
    priority: 25
    matchLabels:
      addons.in-cloud.io/values: cert-manager
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}