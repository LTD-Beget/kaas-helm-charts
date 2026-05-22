{{- define "addonset.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: addonset
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
        priority: 50
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: addon-set
{{- end }}
