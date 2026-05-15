{{- define "common.phase.rules.trust-manager" }}
- name: trust-manager
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
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: trust-manager{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: trust-manager{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
  selector:
    name: trust-manager
    priority: 30
    matchLabels:
      addons.in-cloud.io/values: trust-manager
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
