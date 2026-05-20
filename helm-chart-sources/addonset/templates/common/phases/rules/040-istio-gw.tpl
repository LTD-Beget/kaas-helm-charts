{{- define "common.phase.rules.istio-gw" -}}
- name: istio-gw
  criteria:
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: istio-gw{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: istio-gw{{ .Values.suffix }}
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
    name: istio-gw
    priority: 40
    matchLabels:
      addons.in-cloud.io/values: istio-gw
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
