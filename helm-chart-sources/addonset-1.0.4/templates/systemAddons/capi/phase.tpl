{{- define "capi.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: capi
spec:
  rules:
    - name: system
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
        name: system
        priority: 15
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: capi
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
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: vm-operator
          addons.in-cloud.io/addon: capi
{{- end }}
