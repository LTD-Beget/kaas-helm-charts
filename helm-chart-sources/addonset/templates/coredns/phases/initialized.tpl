{{- define "coredns.phase.initialized" }}
- name: initialized
  criteria:
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: coredns{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: coredns{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
  selector:
    name: initialized
    priority: 10
    matchLabels:
      addons.in-cloud.io/values: initialized
      addons.in-cloud.io/addon: coredns
{{- end }}