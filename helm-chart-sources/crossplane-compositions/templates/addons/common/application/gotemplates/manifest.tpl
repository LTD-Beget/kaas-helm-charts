{{- define "addons.common.application.gotemplates.manifest" }}

  {{- $name := printf "%s" .name }}
  {{- $singular := $name | lower}}
  {{- $singularCamel := include "camelLower" $name }}
  {{- $singularKebab := kebabcase $name }}
  {{- $singularSnake := snakecase $name }}
  {{- $pluralName := printf "%ss" $name }}
  {{- $plural := printf "%ss" $singular }}
  {{- $pluralCamel := printf "%ss" $singularCamel }}
  {{- $pluralKebab := printf "%ss" $singularKebab }}
  {{- $pluralSnake := printf "%ss" $singularSnake }}
  {{- include "common.variables" . | nindent 0 }}
  {{- $appName := printf "%sApp" $singularCamel }}
  {{- printf `

{{- $context                    := dict
  "root"                       .
  "argocdDestinationName"      $argocdDestinationName
  "argocdDestinationNamespace" $argocdDestinationNamespace
  "argocdNamespace"            $argocdNamespace
  "argocdProject"              $argocdProject
  "name"                       $name
  "namespace"                  $namespace
  "customer"                   $customer
  "clusterName"                $clusterName
  "host"                       $host
  "port"                       $port
  "providerConfigRefName"      $providerConfigRefName
  "argocdReleaseName"          $argocdReleaseName
  "trackingID"                 $trackingID
}}

{{- $appReady := dig "resource" "metadata" "annotations" "deployed.in-cloud.io/status" "False" (get $.observed.resources "%s" | default (dict)) }}
{{- $healthApp := (dig "resource" "status" "atProvider" "manifest" "status" "health" "status" "Unknown" (get $.observed.resources "%s" | default (dict))) }}
{{- $syncApp   := (dig "resource" "status" "atProvider" "manifest" "status" "sync" "status" "Unknown" (get $.observed.resources "%s" | default (dict))) }}
{{- if and (eq $healthApp "Healthy") (eq $syncApp "Synced")}}
  {{- $appReady = "True" }}
{{- end }}` $appName $appName $appName }}

  {{- printf `
{{ $userValues                  := default (dict) .observed.composite.resource.spec.values }}

{{- define "default.values" }}
%s
{{- end }}
{{- $defaultValues := include "default.values" $context | fromYaml | default dict }}

{{- define "immutable.values" }}
%s
{{- end }}
{{- $immutableValues := include "immutable.values" $context | fromYaml | default dict }}

` (.default | default "" ) (.immutable | default "" ) }}

{{- merge (.manifest | default dict) (include "addons.common.application.gotemplates.object" . | fromYaml) | toYaml }}

{{- end }}
