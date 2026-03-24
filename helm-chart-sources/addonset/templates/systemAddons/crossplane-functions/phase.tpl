{{- define "crossplane-functions.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: crossplane-functions{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: infra
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: crossplane-functions{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
      selector:
        name: infra
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: crossplane-functions
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
          addons.in-cloud.io/addon: crossplane-functions
    - name: system-and-initialized
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters-infra
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "true"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: crossplane-functions{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
      selector:
        name: system-and-initialized
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: system-and-initialized
          addons.in-cloud.io/addon: crossplane-functions
{{- end }}
