{{- define "goTemplate.addonSet" -}}
  {{ printf `
{{- $environment                      := index .context "apiextensions.crossplane.io/environment" }}

{{- $baseName                         := $environment.base.name }}
{{- $baseNamespace                    := $environment.base.namespace }}
{{- $baseCustomer                     := $environment.base.customer }}
{{- $addonSetProviderConfigRefName    := $environment.addonSet.providerConfigRef.name }}{{/* удалить */}}
{{- $commonArgocdDestinationName      := $environment.common.argocd.destination.name  }}
{{- $commonArgocdNamespace            := $environment.common.argocd.namespace }}
{{- $commonArgocdProject              := $environment.common.argocd.project }}
{{- $commonClusterName                := $environment.common.cluster.name }}
{{- $commonClusterHost                := $environment.common.cluster.host }}
{{- $commonClusterPort                := $environment.common.cluster.port }}
{{- $commonProviderConfigRefName      := $environment.common.providerConfigRef.name }}
{{- $commonTrackingID                 := $environment.common.trackingID }}
{{- $commonXcluster                   := $environment.common.xcluster }}
{{- $currentProviderConfigRefName     := $environment.current.providerConfigRef.name }}

{{- $addons := .observed.composite.resource.spec.addons }}
{{- range $key, $value := $addons }}
  {{- with $value }}
    {{- $AddonCreated := "False" }}
    {{- $apiVersion := .apiVersion }}
    {{- $chart := dig "chart" "" . }}
    {{- $kind := .kind }}
    {{- $name := printf "%%s-%%s" $commonClusterName ($key | lower) }}
    {{- $namespace := .namespace }}
    {{- $path := dig "path" "" . }}
    {{- $permitionToCreateAddon := "True" }}
    {{- $releaseName := dig "releaseName" "" . }}
    {{- $repoURL := dig "repoURL" "" . }}
    {{- $targetRevision := dig "targetRevision" "" . }}
    {{- $values := get . "values" | default (dict) }}
    {{- $version := .version }}
    {{- if hasKey $.observed.resources $key }}
      {{- $AddonCreated = "True" }}
    {{- else }}
      {{- if and (hasKey . "dependsOn") (gt (len .dependsOn) 0) }}
        {{- range .dependsOn }}
          {{- $statusReadyExists := "False" }}
          {{- range (dig "resource" "status" "conditions" (list) (get $.observed.resources . | default (dict))) }}
            {{- if (eq .type "Ready")  }}
              {{- $statusReadyExists = "True" }}
              {{- if (ne .status "True") }}
                {{- $permitionToCreateAddon = "False" }}
              {{- end }}
            {{- end }}
          {{- end }}
          {{- if (ne $statusReadyExists "True") }}
            {{- $permitionToCreateAddon = "False" }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if or (eq $permitionToCreateAddon "True") (eq $AddonCreated "True") }}

---
apiVersion: {{ $apiVersion }}
kind: {{ $kind }}
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: {{ $key }}
    argocd.argoproj.io/tracking-id: {{ $commonTrackingID }}
  name: {{ $name }}
  namespace: {{ $baseNamespace }}
spec:
  argocd:
      {{- if $chart }}
    chart: {{ $chart }}
      {{- end }}
    destination:
      name: {{ $commonArgocdDestinationName }}
      namespace: {{ $namespace }}
    namespace: {{ $commonArgocdNamespace }}
      {{- if $path }}
    path: {{ $path }}
      {{- end }}
    project: {{ $commonArgocdProject }}
      {{- if $releaseName }}
    releaseName: {{ $releaseName }}
      {{- end }}
      {{- if $repoUrl }}
    repoUrl: {{ $repoUrl }}
      {{- end }}
      {{- if $targetRevision }}
    targetRevision: {{ $targetRevision }}
      {{- end }}
    trackingID: {{ $commonTrackingID }}
  cluster: 
    name: {{ $commonClusterName }}
    host: {{ $commonClusterHost }}
    port: {{ $commonClusterPort }}
    xcluster: {{ $commonXcluster }}
  compositeDeletePolicy: Foreground
  providerConfigRef:
    name: {{ $commonProviderConfigRefName }}
  values:
    {{ $values | toYaml | nindent 10 }}
  version: v1alpha1

    {{- end }}
  {{- end }}
{{- end }}

{{- $xAddonReady := "False" }}

{{- range (default (list) .observed.composite.resource.status.conditions ) }}
  {{- if eq .type "Ready" }}
    {{- $xAddonReady = (.status) }}
  {{- end }}
{{- end }}

---
apiVersion: kubernetes.crossplane.io/v1alpha2
kind: Object
metadata:
  annotations:
    gotemplating.fn.crossplane.io/composition-resource-name: addonSetStatus
  name: {{ $baseName }}-status
spec:
  forProvider:
    manifest:
      apiVersion: in-cloud.io/v1alpha1
      kind: XAddonSet
      metadata:
        annotations:
{{- if eq $xAddonReady "True" }}
          status.in-cloud.io/ready: {{ $xAddonReady | quote }}
{{- end }}
        name: {{ $baseName }}
      spec:
        addonStatus:
{{- range $key, $value := $addons }}
  {{- with $value }}
          {{ $key }}:
    {{- $status     := dig "resource" "status" (dict) (get $.observed.resources $key | default (dict)) }}
    {{- $conditions := dig "conditions" (list) ($status) }}
    {{- $health     := dig "health" "Unknown" ($status) }}
    {{- $deployed   := dig "deployed" false ($status) }}
    {{- $ready      := "False" }}
    {{- range $conditions}}
      {{- if eq .type "Ready" }}
        {{- $ready = .status | quote }}
      {{- end }}
    {{- end }}
            health: {{ $health }}
            deployed: {{ $deployed }}
            ready: {{ $ready }}
            conditions:
              {{- $conditions | toYaml | nindent 14 }}
  {{- end }}
{{- end }}
  managementPolicies:
    - 'Update'
    - 'Observe'
  providerConfigRef:
    name: {{ $currentProviderConfigRefName }}
  readiness:
    policy: SuccessfulCreate
  watch: true
  ` }}
{{- end -}}
