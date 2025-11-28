{{- define "xcertificate.certificate" -}}
  {{ printf `
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  annotations:
  {{- range $annotation := $certificateAnnotations }}
    {{ $annotation.name }}: {{ $annotation.value }}
  {{- end }}
  labels:
  {{- range $label := $certificateLabels }}
    {{ $label.name }}: {{ $label.value }}
  {{- end }}
  name: {{ $certificateName }}
  namespace: {{ $commonNamespace }}
spec: 
  isCA: {{ $certificateIsCa }}
  commonName: {{ $certificateCommonName }}
  secretName: {{ $certificateSecretName }}
  duration: {{ $certificateDuration }}
  renewBefore: {{ $certificateRenewBefore }}
  privateKey:
    algorithm: RSA
    size: 2048
    rotationPolicy: {{ $certificateRotationPolicy }}
  {{- if $certificateIpAddresses }}
  ipAddresses:
    {{- range $ipAddress := $certificateIpAddresses }}
    - {{ $ipAddress }}
    {{- end }}
  {{- end }}
  {{- if $certificateDnsNames }}
  dnsNames:
    {{- range $dnsName := $certificateDnsNames }}
      - {{ $dnsName }}
    {{- end }}
  {{- end }}
  issuerRef:
    name: {{ $issuerSignerName }}
    kind: {{ $issuerSignerKind }}
    group: {{ regexReplaceAll "/.*" $issuerSignerApiVersion "" }}
  {{- if $certificateSubjectOrganizations }}
  subject:
    organizations:
    {{- range $organization := $certificateSubjectOrganizations }}
      - {{ $organization }}
    {{- end }}
  {{- end }}
  {{- if $certificateUsages }}
  usages:
    {{- range $usage := $certificateUsages }}
    - {{ $usage }}
    {{- end }}
  {{- end }}
  secretTemplate:
    labels:
    {{- range $label := $certificateSecretLabels }}
      {{ $label.name }}: {{ $label.value }}
    {{- end }}
  ` }}
{{- end -}}
