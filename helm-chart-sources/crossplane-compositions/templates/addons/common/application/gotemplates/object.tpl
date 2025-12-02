{{- define "addons.common.application.gotemplates.object" }}
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
  {{- $appName := printf "%sApp" $singularCamel }}

spec:
  project: {{ "\"{{ $argocdProject }}\"" }}
  destination:
    namespace: {{ "\"{{ $argocdDestinationNamespace }}\"" }}
    name: {{ "\"{{ $argocdDestinationName }}\"" }}
  syncPolicy:
    managedNamespaceMetadata:
      labels:
        in-cloud.io/clusterName: {{ "\"{{ $clusterName }}\"" }}
        in-cloud.io/caBundle: "approved"
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
  source:
    path: {{ "\"{{ $path }}\"" }}
    chart: {{ "\"{{ $chart }}\"" }}
    repoURL: {{ "\"{{ $repoURL }}\"" }}
    targetRevision: {{ "\"{{ $targetRevision }}\"" }}
    {{- if .pluginName }}
    helm: null
    plugin:
      name: {{ "\"{{ $pluginName }}\"" }}
      env:
        - name: "HELM_VALUES"
          value: {{ "\"{{ merge $immutableValues $userValues $defaultValues | toYaml | b64enc }}\"" }}
        - name: "RELEASE_NAME"
          value: {{ "\"{{ $argocdReleaseName }}\"" }}
    {{- else }}
    helm:
      releaseName: {{ "\"{{ $argocdReleaseName }}\"" }}
      values: |-
        {{ "{{ $mergedValues := merge $immutableValues $userValues $defaultValues }}" }}
        {{ "{{ $mergedValues | toYaml | nindent 14 }}" }}
    plugin: null
    {{- end }}
{{- end }}
