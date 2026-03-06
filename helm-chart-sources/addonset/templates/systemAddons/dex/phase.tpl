{{- define "dex.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: dex{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: cert-manager
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.phaseValuesSelector[?(@.name=='initialized-2')]
          operator: Exists
      selector:
        name: cert-manager
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: cert-manager
          addons.in-cloud.io/addon: dex
    - name: system
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{ end }}
            namespace: beget-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
      selector:
        name: system
        priority: 15
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: dex
    - name: vm-operator
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: vm-operator
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: vm-operator
          addons.in-cloud.io/addon: dex
    - name: istio-base
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: istio-base{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: argocd{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: istio-base
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: istio-base
          addons.in-cloud.io/addon: dex
{{- end }}
