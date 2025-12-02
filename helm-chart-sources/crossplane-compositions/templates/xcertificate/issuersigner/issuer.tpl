{{- define "xcertificate.issuersigner" -}}
  {{ printf `
{{ if eq $issuerSignerType "selfsigned" }}
apiVersion: {{ $issuerSignerApiVersion }}
kind: {{ $issuerSignerKind }}
metadata:
  annotations:
  {{- range $annotation := $issuerSignerAnnotations }}
    {{ $annotation.name }}: {{ $annotation.value }}
  {{- end }}
  labels:
  {{- range $label := $issuerSignerLabels }}
    {{ $label.name }}: {{ $label.value }}
  {{- end }}
  name: {{ $issuerSignerName }}
  {{ if eq $issuerSignerKind "Issuer" }}
  namespace: {{ $commonNamespace }}
  {{ end }}
spec:
  selfSigned: {}
{{ end }}
  ` }}
{{- end -}}
