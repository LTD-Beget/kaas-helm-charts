{{- define "trust-manager.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: trust-manager{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: vm-operator
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: vm-operator
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: vm-operator
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: vm-operator
          addons.in-cloud.io/addon: trust-manager
    - name: system
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{ end }}
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "True"
      selector:
        name: system
        priority: 50
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: trust-manager
{{- end }}
