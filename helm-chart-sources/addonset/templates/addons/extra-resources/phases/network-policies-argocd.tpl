{{- define "extra-resources.phase.rules.network-policies-argocd" -}}
- name: network-policies-argocd
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
        name: argocd{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: Addon
        name: cilium{{ .Values.suffix }}
      jsonPath: $.status.deployed
      operator: Equal
      value: true
      keep: false
    # TODO политику нужно отключить после добавления целевых политик
    # добавить критерий
    # {{- if eq .Values.environment "infra" }}
    # - source:
    #     apiVersion: addons.in-cloud.io/v1alpha1
    #     kind: AddonPhase
    #     name: argocd{{ .Values.suffix }}
    #   jsonPath: $.status.ruleStatuses[?(@.name=='network-policies')].deployed
    #   operator: NotExists
    #   keep: false
    #   # value: false
    # {{- end }}
  selector:
    name: network-policies-argocd
    priority: 67
    matchLabels:
      addons.in-cloud.io/values: network-policies-argocd
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
