{{- define "addons.capiclusterclass" }}
name: CapiClusterClass
debug: false
path: .
repoURL: https://gitlab.beget.ru/cloud/k8s/charts/in-cloud-capi.git
{{- $addonValue := dig "composite" "addons" "capiclusterclass" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
