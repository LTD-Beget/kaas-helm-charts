{{- define "coredns.phase.vm-operator" }}
- name: vm-operator
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
        name: vm-operator{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: vm-operator{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
  selector:
    name: vm-operator
    priority: 30
    matchLabels:
      addons.in-cloud.io/values: vm-operator
      addons.in-cloud.io/addon: coredns
{{- end }}