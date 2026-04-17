{{- define "addons-operator.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: certificate-set{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
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
        priority: 25
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: certificate-set
{{- end }}
