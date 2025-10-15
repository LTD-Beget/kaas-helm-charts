#VariableName  DefaultValue  FromFieldPath  ToFieldPath  Type  Format
{{- define "xcertificateset.variables.template" -}}
  {{- $vars := dict
    "commonAnnotations"           (list "(list)"          "common.annotations"            "common.annotations"            "list"    "-"  )
    "commonLabels"                (list "(list)"          "common.labels"                 "common.labels"                 "list"    "-"  )
    "commonNamespace"             (list "$baseNamespace"  "common.namespace"              "common.namespace"              "string"  "%s" )
    "commonProviderConfigRefName" (list "\"default\""     "common.providerConfigRef.name" "common.providerConfigRef.name" "string"  "%s" )
  -}}
  {{- $order := list
      "commonAnnotations"
      "commonLabels"
      "commonNamespace"
      "commonProviderConfigRefName"
  -}}
  {{- dict "vars" $vars "order" $order | toYaml -}}
{{- end -}}

{{- define "xcertificateset.variables.emit" -}}
  {{- $doc  := include "xcertificateset.variables.template" . | fromYaml -}}
  {{- $vars := $doc.vars -}}
  {{- range $name := $doc.order -}}
    {{- $v    := index $vars $name -}}
    {{- $def  := index $v 0 -}}
    {{- $dst  := index $v 2 -}}
{{ printf "{{- $%s := default %s $environment.%s -}}\n" $name $def $dst }}
  {{- end -}}
{{- end -}}

{{- define "xcertificateset.variables" -}}
  {{ printf `{{- $environment                      := index .context "apiextensions.crossplane.io/environment" }}

{{- $baseCustomer                     :=                            $environment.base.customer }}
{{- $baseName                         :=                            $environment.base.name }}
{{- $baseNamespace                    :=                            $environment.base.namespace }}
  ` }}
  {{- include "xcertificateset.variables.emit" . | nindent 0 }}
{{- end -}}
