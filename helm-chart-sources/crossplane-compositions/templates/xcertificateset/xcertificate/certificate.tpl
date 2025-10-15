{{- define "xcertificateset.xcertificate" -}}
  {{ include "xcertificateset.variables" . | nindent 0 }}
  {{ printf `
{{- $common                 := deepCopy (default (dict) .observed.composite.resource.spec.common) -}}
{{- $ProviderConfigRefName  := default "default" (dig "providerConfigRef" "name" "" .observed.composite.resource.spec) -}}
{{- range $key, $value      := (default (dict) .observed.composite.resource.spec.xcertificates) -}}
  {{- $xCertSuffix          := $value.common.suffix | default "" }}
  {{- $xCertName            := $value.common.name | default "" }}
  {{- $xCertName            = default (printf "%%s%%s" $baseName $xCertSuffix) $xCertName }}
  {{- $xCertificate         := deepCopy (default (dict) $value) -}}
  {{- $c                    := deepCopy (default (dict) (get $xCertificate "common")) -}}
  {{- $_                    := unset $c "name" -}}
  {{- $_                    := unset $c "suffix" -}}
  {{- $_                    := set $xCertificate "common" $c -}}
  {{- $xCertificate         = merge $xCertificate (dict "common" $common) -}}
  {{- $_                    := set $xCertificate "ProviderConfigRef" (dict "name" $ProviderConfigRefName) -}}
  {{- $xCertificateReady    := "False" -}}
  {{- range (dig "resource" "status" "conditions" (list) (get $.observed.resources $key | default (dict))) }}
    {{- if eq .type "Ready" }}
      {{- $xCertificateReady = (.status) }}
    {{- end }}
  {{- end }}

  {{- $certificateCreated := "False" }}
  {{- $permitionToCreateCertificate := "True" }}
  {{- if hasKey $.observed.resources $key }}
    {{- $certificateCreated = "True" }}
  {{- else }}
    {{- if and (hasKey $value "dependsOn") (gt (len $value.dependsOn) 0) }}
      {{- range $value.dependsOn }}
        {{- $statusReadyExists := "False" }}
        {{- range (dig "resource" "status" "conditions" (list) (get $.observed.resources . | default (dict))) }}
          {{- if (eq .type "Ready")  }}
            {{- $statusReadyExists = "True" }}
            {{- if (ne .status "True") }}
              {{- $permitionToCreateCertificate = "False" }}
            {{- end }}
          {{- end }}
        {{- end }}
        {{- if (ne $statusReadyExists "True") }}
          {{- $permitionToCreateCertificate = "False" }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if or (eq $permitionToCreateCertificate "True") (eq $certificateCreated "True") }}
---
apiVersion: in-cloud.io/v1alpha1
kind: XCertificate
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: {{ $key }}
    gotemplating.fn.crossplane.io/ready: {{ $xCertificateReady | quote }}
    debug.in-cloud.io/permitionocreatecertificate: {{ $permitionToCreateCertificate | quote }}
    debug.in-cloud.io/certificatecreated: {{ $certificateCreated | quote }}
  {{- if eq $xCertificateReady "True" }}
    status.in-cloud.io/ready: {{ $xCertificateReady | quote }}
  {{- end }}
  {{- if $xCertificate.common.annotations }}
    {{- range $annotation := $xCertificate.common.annotations }}
    {{ $annotation.name }}: {{ $annotation.value }}
    {{- end }}
  {{- end }}
  {{- if $xCertificate.common.labels }}
  labels:
    {{- range $label := $xCertificate.common.labels }}
    {{ $label.name }}: {{ $label.value }}
    {{- end }}
  {{- end }}
  name: {{ $xCertName }}
spec:
  compositeDeletePolicy: Foreground
  {{- $xCertificate | toYaml | nindent 2 }}

  {{- end -}}
{{- end -}}
  ` }}
{{- end -}}
