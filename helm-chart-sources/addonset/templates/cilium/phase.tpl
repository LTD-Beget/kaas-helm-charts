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
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
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
{{- end }}
