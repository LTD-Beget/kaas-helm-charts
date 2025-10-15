{{- define "xcertificate.certificate.object" -}}
  {{ include "xcertificate.variables" . | nindent 0 }}
  {{ printf `
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: certificate
    gotemplating.fn.crossplane.io/ready: {{ $certificateReady | quote }}
  {{- if eq $certificateReady "True" }}
    status.in-cloud.io/ready: {{ $certificateReady | quote }}
  {{- end }}
  labels:
  {{- range $label := $certificateLabels }}
    {{ $label.name }}: {{ $label.value }}
  {{- end }}
  name: {{ $certificateObjectName }}
spec: 
  forProvider:
    manifest:
  ` }}
  {{- include "xcertificate.certificate" . | nindent 6 }}
  {{ printf `
  providerConfigRef:
    name: {{ $providerConfigRefName }}
  readiness:
    policy: DeriveFromCelQuery
    celQuery: "object.status.conditions.exists(c, c.type == 'Ready' && c.status == 'True')"
  references:
    - patchesFrom:
        apiVersion: kubernetes.crossplane.io/v1alpha2
        kind: Object
        name: {{ $issuerSignerObjectName }}
        fieldPath: "metadata.annotations['status.in-cloud.io/ready']"
      toFieldPath: "metadata.annotations['dependency.in-cloud.io/ready']"
  watch: true
  ` }}
{{- end -}}
