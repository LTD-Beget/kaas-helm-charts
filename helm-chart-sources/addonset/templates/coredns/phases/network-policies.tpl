{{- define "coredns.phase.network-policies" }}
- name: network-policies
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.environment
      operator: Equal
      value: "infra"
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: cilium{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: cilium{{ .Values.suffix }}
      jsonPath: $.spec.variables.dependency
      operator: Equal
      value: "True"
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: AddonPhase
        name: extra-resources
      jsonPath: $.status.ruleStatuses[?(@.name=='network-policies-argocd')].deployed
      operator: Equal
      value: true
  selector:
    name: network-policies
    priority: 35
    matchLabels:
      addons.in-cloud.io/values: network-policies
      addons.in-cloud.io/addon: coredns
{{- end }}