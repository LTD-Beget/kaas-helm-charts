{{- define "incloud-web-resources.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: incloud-web-resources{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: infra
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
        name: infra
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: incloud-web-resources
    - name: system-trivy
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{ end }}
            namespace: beget-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "True"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: trivy-operator{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.status.conditions[?(@.type=='Ready')].status
          operator: Equal
          value: "True"
      selector:
        name: system-trivy
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: system-trivy
          addons.in-cloud.io/addon: incloud-web-resources
{{- end }}
