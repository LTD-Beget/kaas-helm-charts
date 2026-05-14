{{- define "common.phase.rules.istio-base" }}
- name: istio-base
  criteria:
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: istio-base{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: istio-base{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: {{ .Values.addonName }}{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
  selector:
    name: istio-base
    priority: 60
    matchLabels:
      addons.in-cloud.io/values: istio-base
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
