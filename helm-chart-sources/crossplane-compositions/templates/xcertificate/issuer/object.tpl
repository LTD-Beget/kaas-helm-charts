{{- define "xcertificate.issuer.object" -}}
  {{ include "xcertificate.variables" . | nindent 0 }}
  {{ printf `
{{ if $issuerEnabled }}
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: issuer
    gotemplating.fn.crossplane.io/ready: {{ $issuerReady | quote }}
  {{- if eq $issuerReady "True" }}
    status.in-cloud.io/ready: {{ $issuerReady | quote }}
  {{- end }}
  labels:
  {{- range $label := $issuerLabels }}
    {{ $label.name }}: {{ $label.value }}
  {{- end }}
  name: {{ $issuerObjectName }}
spec: 
  forProvider:
    manifest:
  ` }}
  {{- include "xcertificate.issuer" . | nindent 6 }}
  {{ printf `
  providerConfigRef:
    name: {{ $providerConfigRefName }}
  readiness:
    policy: DeriveFromCelQuery
    celQuery: "object.status.conditions.exists(c, c.type == 'Ready' && c.status == 'True')"
  references:
    - dependsOn:
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        name: {{ $certificateObjectName }}
    - patchesFrom:
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        name: {{ $certificateObjectName }}
        fieldPath: "metadata.annotations['status.in-cloud.io/ready']"
      toFieldPath: "metadata.annotations['dependency.in-cloud.io/ready']"
  watch: true
{{ end }}
  ` }}
{{- end -}}
