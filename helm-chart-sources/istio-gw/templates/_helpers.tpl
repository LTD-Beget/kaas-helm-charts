{{- define "gateway-wrapper.name" -}}
{{- $gateway := .Values.gateway | default dict -}}
{{- if eq .Release.Name "RELEASE-NAME" -}}
{{- $gateway.name | default "istio-ingressgateway" -}}
{{- else -}}
{{- $gateway.name | default .Release.Name | default "istio-ingressgateway" -}}
{{- end -}}
{{- end }}

{{- define "gateway-wrapper.selectorLabels" -}}
{{- $gateway := .Values.gateway | default dict -}}
{{- $labels := $gateway.labels | default dict -}}
{{- $name := include "gateway-wrapper.name" . -}}
app: {{ get $labels "app" | default $name | quote }}
istio: {{ get $labels "istio" | default ($name | trimPrefix "istio-") | quote }}
{{- end }}

{{- define "gateway-wrapper.labels" -}}
{{- $gateway := .Values.gateway | default dict -}}
{{- $labels := $gateway.labels | default dict -}}
{{ include "gateway-wrapper.selectorLabels" . }}
{{- range $key, $val := $labels }}
{{- if and (ne $key "app") (ne $key "istio") }}
{{ $key | quote }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}