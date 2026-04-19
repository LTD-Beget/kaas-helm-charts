{{- define "validating-admission-policies.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: validating-admission-policies{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    {{- if eq .Values.environment "infra" }}
    - name: infra
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters-infra
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
          keep: false
      selector:
        name: infra
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: validating-admission-policies
    {{- end }}
    {{- if eq .Values.environment "client" }}
    - name: client
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters-client
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "client"
          keep: false
      selector:
        name: client
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: client
          addons.in-cloud.io/addon: validating-admission-policies
    {{- end }}
{{- end }}
