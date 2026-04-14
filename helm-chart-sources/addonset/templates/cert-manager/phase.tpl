{{- define "cert-manager.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: initialized
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
      selector:
        name: initialized
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: initialized
          addons.in-cloud.io/addon: cert-manager
    - name: initialized-2
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.phaseValuesSelector[?(@.name=='initialized')]
          operator: Exists
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
      selector:
        name: initialized-2
        priority: 13
        matchLabels:
          addons.in-cloud.io/values: initialized-2
          addons.in-cloud.io/addon: cert-manager
    # - name: infra
    #   criteria:
    #     - source:
    #         apiVersion: v1
    #         kind: ConfigMap
    #         name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
    #         namespace: {{ .Values.companyPrefix }}-system
    #       jsonPath: $.data.environment
    #       operator: Equal
    #       value: "infra"
    #   selector:
    #     name: infra
    #     priority: 15
    #     matchLabels:
    #       addons.in-cloud.io/values: infra
    #       addons.in-cloud.io/addon: cert-manager
    - name: vm-operator
      criteria:
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
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: vm-operator
          addons.in-cloud.io/addon: cert-manager
    - name: system
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "true"
      selector:
        name: system
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: cert-manager
{{- end }}
