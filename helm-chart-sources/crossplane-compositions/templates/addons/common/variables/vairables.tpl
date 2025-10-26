#VariableName  DefaultValue  FromFieldPath  ToFieldPath  Type  Format
{{- define "common.variables.template" -}}
  {{- $singularKebab := kebabcase .name }}
  {{- $vars := dict
    "argocdDestinationName"       (list "\"\""                                      "argocd.destination.name"       "argocd.destination.name"       "string"  "%s"    )
    "argocdDestinationNamespace"  (list "\"\""                                      "argocd.destination.namespace"  "argocd.destination.namespace"  "string"  "%s"    )
    "argocdNamespace"             (list "\"\""                                      "argocd.namespace"              "argocd.namespace"              "string"  "%s"    )
    "argocdProject"               (list "\"\""                                      "argocd.project"                "argocd.project"                "string"  "%s"    )
    "argocdReleaseName"           (list (printf "\"%s\"" $singularKebab)            "argocd.releaseName"            "argocd.releaseName"            "string"  "%s"    )
    "chart"                       (list (printf "\"%s\"" (default "" .chart))       "argocd.chart"                  "argocd.chart"                  "string"  "%s"    )
    "clusterName"                 (list "\"\""                                      "cluster.name"                  "cluster.name"                  "string"  "%s"    )
    "finalizerDisabled"           (list "false"                                     "argocd.finalizerDisabled"      "argocd.finalizerDisabled"      "bool"    "%s"    )
    "host"                        (list "\"\""                                      "cluster.host"                  "cluster.host"                  "string"  "%s"    )
    "path"                        (list (printf "\"%s\"" (default "" .path))        "argocd.path"                   "argocd.path"                   "string"  "%s"    )
    "port"                        (list "6443"                                      "cluster.port"                  "cluster.port"                  "string"  "%.0f"  )
    "providerConfigRefName"       (list "\"default\""                               "providerConfigRef.name"        "providerConfigRef.name"        "string"  "%s"    )
    "repoURL"                     (list (printf "\"%s\"" .repoURL)                  "argocd.repoURL"                "argocd.repoURL"                "string"  "%s"    )
    "pluginName"                  (list (printf "\"%s\"" (default "" .pluginName))  "argocd.pluginName"             "argocd.pluginName"             "string"  "%s"    )
    "xclusterName"                (list "\"\""                                      "cluster.xcluster"              "cluster.xcluster.name"         "string"  "%s"    )
    "targetRevision"              (list (printf "\"%s\"" .targetRevision)           "argocd.targetRevision"         "argocd.targetRevision"         "string"  "%s"    )
    "trackingID"                  (list "\"\""                                      "argocd.trackingID"             "trackingID"                    "string"  "%s"    )
  -}}
  {{- $order := list
    "argocdDestinationName"
    "argocdDestinationNamespace"
    "argocdNamespace"
    "argocdProject"
    "argocdReleaseName"
    "chart"
    "clusterName"
    "finalizerDisabled"
    "host"
    "path"
    "port"
    "providerConfigRefName"
    "repoURL"
    "pluginName"
    "xclusterName"
    "targetRevision"
    "trackingID"
  -}}
  {{- dict "vars" $vars "order" $order | toYaml -}}
{{- end -}}

{{- define "common.variables.emit" -}}
  {{- $doc  := include "common.variables.template" . | fromYaml -}}
  {{- $vars := $doc.vars -}}
  {{- range $name := $doc.order -}}
    {{- $v    := index $vars $name -}}
    {{- $def  := index $v 0 -}}
    {{- $dst  := index $v 2 -}}
{{ printf "{{- $%s := default %s $environment.%s -}}\n" $name $def $dst }}
  {{- end -}}
{{- end -}}

{{- define "common.variables" -}}
  {{ printf `{{- $environment                      := index .context "apiextensions.crossplane.io/environment" }}

{{- $customer                          :=                            $environment.base.customer }}
{{- $name                              :=                            $environment.base.name }}
{{- $namespace                         :=                            $environment.base.namespace }}
  ` }}
  {{- include "common.variables.emit" . | nindent 0 }}

{{- end -}}
