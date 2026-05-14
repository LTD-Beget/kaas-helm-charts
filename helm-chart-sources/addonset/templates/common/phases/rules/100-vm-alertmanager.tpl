{{- define "common.phase.rules.vm-alertmanager" }}
- name: vm-alertmanager
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
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: vm-alertmanager{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: vm-alertmanager{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
  selector:
    name: vm-alertmanager
    priority: 100
    matchLabels:
      addons.in-cloud.io/values: vm-alertmanager
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
