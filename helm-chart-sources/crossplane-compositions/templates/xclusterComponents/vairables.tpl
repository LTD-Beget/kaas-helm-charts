#VariableName  DefaultValue  FromFieldPath  ToFieldPath  Type  Format
{{- define "xclusterComponents.variables.template" -}}
  {{- $vars := dict
    "argocdDestinationName"      (list "\"mock\""       "argocd.destination.name"        "argocd.destination.name"       "string"           "%s"  )
    "argocdDestinationNamespace" (list "\"mock\""       "argocd.destination.namespace"   "argocd.destination.namespace"  "string"           "%s"  )
    "argocdDestinationProject"   (list "\"mock\""       "argocd.destination.project"     "argocd.destination.project"    "string"           "%s"  )
    "clusterName"                (list "\"mock\""       "cluster.name"                   "cluster.name"                  "string"           "%s"  )
    "clusterHost"                (list "\"mock\""       "cluster.host"                   "cluster.host"                  "string"           "%s"  )
    "clusterPort"                (list "6443"           "cluster.port"                   "cluster.port"                  "integer"          "%s"  )
    "systemEnabled"              (list "false"          "system.enabled"                 "system.enabled"                "boolean"          "%v"  )
    "trackingID"                 (list "\"mock\""       "trackingID"                     "trackingID"                    "string"           "%s"  )
    "xcluster"                   (list "\"mock\""       "xcluster"                       "xcluster"                      "string"           "%s"  )
  -}}
  {{- $order := list
    "argocdDestinationName"
    "argocdDestinationNamespace"
    "argocdDestinationProject"
    "clusterName"
    "clusterHost"
    "clusterPort"
    "systemEnabled"
    "trackingID"
    "xcluster"
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
  ` }}
  {{- include "xclusterComponents.variables.emit" . | nindent 0 }}

{{- end -}}
