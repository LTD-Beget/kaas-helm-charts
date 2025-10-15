{{- define "xcertificate.issuer" -}}
  {{ printf `
apiVersion: {{ $issuerApiVersion }}
kind: {{ $issuerKind }}
metadata:
  annotations:
  {{- range $annotation := $issuerAnnotations }}
    {{ $annotation.name }}: {{ $annotation.value }}
  {{- end }}
  labels:
  {{- range $label := $issuerLabels }}
    {{ $label.name }}: {{ $label.value }}
  {{- end }}
  name: {{ $issuerName }}
  {{ if eq $issuerKind "Issuer" }}
  namespace: {{ $commonNamespace }}
  {{ end }}
spec:
  ca:
    secretName: {{ $certificateSecretName }}
  ` }}
{{- end -}}
