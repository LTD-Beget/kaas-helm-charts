{{- define "extra-resources.phase.rules.customer-network-policies" -}}
- name: customer-network-policies
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.systemEnabled
      operator: Equal
      value: "true"
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: argocd
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: cilium
      jsonPath: $.status.deployed
      operator: Equal
      value: true
  selector:
    name: customer-network-policies
    priority: 69
    matchLabels:
      addons.in-cloud.io/values: customer-network-policies
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
