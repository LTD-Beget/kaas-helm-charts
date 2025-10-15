{{- define "xcertificate.issuersigner.object" -}}
  {{ include "xcertificate.variables" . | nindent 0 }}
  {{ printf `
{{ if eq $issuerSignerType "selfsigned" }}
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: issuerSigner
    gotemplating.fn.crossplane.io/ready: {{ $issuerSignerReady | quote }}
  {{- if eq $issuerSignerReady "True" }}
    status.in-cloud.io/ready: {{ $issuerSignerReady | quote }}
  {{- end }}
  labels:
  {{- range $label := $issuerSignerLabels }}
    {{ $label.name }}: {{ $label.value }}
  {{- end }}
  name: {{ $issuerSignerObjectName }}
spec: 
  forProvider:
    manifest:
  ` }}
  {{- include "xcertificate.issuersigner" . | nindent 6 }}
  {{ printf `
  providerConfigRef:
    name: {{ $providerConfigRefName }}
  readiness:
    policy: DeriveFromCelQuery
    celQuery: "object.status.conditions.exists(c, c.type == 'Ready' && c.status == 'True')"
  watch: true
{{ end }}
  ` }}
{{- end -}}
