{{- define "helm-inserter.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: helm-inserter
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
          addons.in-cloud.io/addon: helm-inserter
{{- end }}
