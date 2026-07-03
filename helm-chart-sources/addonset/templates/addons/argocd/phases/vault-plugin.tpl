{{- define "argocd.phase.rules.vault-plugin" -}}
- name: vault-plugin
  criteria:
    - source:
        apiVersion: v1
        kind: ConfigMap
        name: {{ .Values.parametersName }}
        namespace: {{ .Values.companyPrefix }}-system
      jsonPath: $.data.environment
      operator: Equal
      value: "infra"
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: AddonPhase
        name: argocd
      jsonPath: $.status.ruleStatuses[?(@.name=='infra')].deployed
      operator: Equal
      value: true
    - source:
        apiVersion: addons.in-cloud.io/v1alpha1
        kind: AddonPhase
        name: argocd
        namespace: {{ .Values.companyPrefix }}-argocd
      jsonPath: $.status.ruleStatuses[?(@.name=='network-policies-argocd')].deployed
      operator: Equal
      value: true
    - source:
        apiVersion: v1
        kind: Secret
        name: avp-config
        namespace: {{ .Values.companyPrefix }}-argocd
      jsonPath: $.metadata.labels['avp-secret.in-cloud.io/updated']
      operator: Exists
  selector:
    name: infra
    priority: 20
    matchLabels:
      addons.in-cloud.io/values: vault-plugin
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
