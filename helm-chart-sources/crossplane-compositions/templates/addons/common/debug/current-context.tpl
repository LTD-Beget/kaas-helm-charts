{{- define "addons.common.debug.current-context" }}

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
  {{ include "common.variables" . | nindent 0 }}

  {{- printf `

---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  name: {{ $name }}-current-context
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: %sDebug
    gotemplating.fn.crossplane.io/ready: "True"
    kubectl.kubernetes.io/last-applied-configuration: ""
spec:
  forProvider:
    manifest:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        annotations:
          kubectl.kubernetes.io/last-applied-configuration: ""
          argocd.argoproj.io/tracking-id: {{ $trackingID }}
        name: {{ $name }}-current-context
        namespace: {{ $namespace }}
      data:
  {{- with (index .context "apiextensions.crossplane.io/environment") }}
        context.apiextensions.crossplane.io-environment: |
          {{ . | toYaml | nindent 10 }}
  {{- end }}
        vars: |
          argocdDestinationName: {{ $argocdDestinationName }}
          argocdDestinationNamespace: {{ $argocdDestinationNamespace }}
          argocdNamespace: {{ $argocdNamespace }}
          name: {{ $name }}
          namespace: {{ $namespace }}
          customer: {{ $customer }}
          clusterName: {{ $clusterName }}
          host: {{ $host }}
          port: {{ $port }}
          providerConfigRefName: {{ $providerConfigRefName }}
          trackingID: {{ $trackingID }}
  ` $singularCamel }}
{{- end }}
