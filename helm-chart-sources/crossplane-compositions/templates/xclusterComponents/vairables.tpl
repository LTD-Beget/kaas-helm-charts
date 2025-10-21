#VariableName  DefaultValue  FromFieldPath  ToFieldPath  Type  Format
{{- define "xclusterComponents.variables.template" -}}
  {{- $vars := dict
    "clusterName" (list "\"\""  "clusterName" "clusterName" "string"  "%s"  )
    "trackingID"  (list "\"\""  "trackingID"  "trackingID"  "string"  "%s"  )
  -}}
  {{- $order := list
    "clusterName"
    "trackingID"
  -}}
  {{- dict "vars" $vars "order" $order | toYaml -}}
{{- end -}}

{{- define "xclusterComponents.variables.emit" -}}
  {{- $doc  := include "xclusterComponents.variables.template" . | fromYaml -}}
  {{- $vars := $doc.vars -}}
  {{- range $name := $doc.order -}}
    {{- $v    := index $vars $name -}}
    {{- $def  := index $v 0 -}}
    {{- $dst  := index $v 2 -}}
{{ printf "{{- $%s := default %s $environment.%s -}}\n" $name $def $dst }}
  {{- end -}}
{{- end -}}

{{- define "xclusterComponents.variables" -}}
  {{ printf `{{- $environment                      := index .context "apiextensions.crossplane.io/environment" }}

{{- $customer                          :=                            $environment.base.customer }}
{{- $name                              :=                            $environment.base.name }}
{{- $namespace                         :=                            $environment.base.namespace }}
  ` }}
  {{- include "xclusterComponents.variables.emit" . | nindent 0 }}

{{- end -}}
