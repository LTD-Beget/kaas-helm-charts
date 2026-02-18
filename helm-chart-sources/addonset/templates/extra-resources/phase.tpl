{{- define "extra-resources.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: extra-resources{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: certificate-set
      criteria:
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: beget-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
      selector:
        name: certificate-set
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: certificate-set
          addons.in-cloud.io/addon: extra-resources  
{{- end }}
