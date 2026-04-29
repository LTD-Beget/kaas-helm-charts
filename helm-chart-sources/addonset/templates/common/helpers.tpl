{{- define "common.addonValue" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonValue
metadata:
  name: {{ .Values.addonName }}-{{ .Values.addonValueName }}
  labels:
    addons.in-cloud.io/values: {{ .Values.addonValueName }}
    addons.in-cloud.io/addon: {{ .Values.addonName }}
spec:
  values: |
{{- end }}
