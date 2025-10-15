{{/* lowerCamelCase: myTestString — единственное, чего нет в Sprig */}}
{{- define "camelLower" -}}
{{- $s := camelcase . -}}
{{- if gt (len $s) 0 -}}
{{- printf "%s%s" (lower (substr 0 1 $s)) (substr 1 (len $s) $s) -}}
{{- else -}}{{- $s -}}{{- end -}}
{{- end -}}
