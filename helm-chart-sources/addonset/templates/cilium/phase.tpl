{{- define "cilium.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: cilium{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: vm-operator
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.phaseValuesSelector[?(@.name=='initialized-2')]
          operator: Exists
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
      selector:
        name: vm-operator
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: "vm-operator"
          addons.in-cloud.io/addon: cilium

    {{- if eq .Values.environment "infra" }}
    - name: network-policies
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters-infra
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
      selector:
        name: network-policies
        priority: 35
        matchLabels:
          addons.in-cloud.io/values: network-policies
          addons.in-cloud.io/addon: cilium
    {{- end }}

    {{- if eq .Values.environment "infra" }}
    - name: enforcement-always
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters-infra
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: AddonPhase
            name: coredns
          jsonPath: $.status.ruleStatuses[?(@.name=='network-policies')].deployed
          operator: Equal
          value: true
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: AddonPhase
            name: argocd
          jsonPath: $.status.ruleStatuses[?(@.name=='network-policies')].deployed
          operator: Equal
          value: true
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: AddonPhase
            name: addons-operator
          jsonPath: $.status.ruleStatuses[?(@.name=='network-policies')].deployed
          operator: Equal
          value: true
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: AddonPhase
            name: cilium
          jsonPath: $.status.ruleStatuses[?(@.name=='network-policies')].deployed
          operator: Equal
          value: true
        # - source:
        #     apiVersion: addons.in-cloud.io/v1alpha1
        #     kind: AddonPhase
        #     name: extra-resources
        #   jsonPath: $.status.ruleStatuses[?(@.name=='network-policies-argocd')].deployed
        #   operator: Equal
        #   value: true
      selector:
        name: enforcement-always
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: enforcement-always
          addons.in-cloud.io/addon: cilium
    {{- end }}
{{- end }}
