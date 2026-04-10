{{- define "trust-manager.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: trust-manager{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: infra
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
      selector:
        name: infra
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: trust-manager
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
          addons.in-cloud.io/values: vm-operator
          addons.in-cloud.io/addon: trust-manager
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
        priority: 50
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: trust-manager
    - name: cilium
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cilium{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cilium{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
      selector:
        name: cilium
        priority: 50
        matchLabels:
          addons.in-cloud.io/values: cilium
          addons.in-cloud.io/addon: trust-manager
{{- end }}
