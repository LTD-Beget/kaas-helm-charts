{{- define "addons.crossplanexcluster" }}
name: CrossplaneXcluster
debug: false
path: .
repoURL: https://gitlab.beget.ru/cloud/k8s/charts/crossplane-xcluster.git
{{- $addonValue := dig "composite" "addons" "crossplanexcluster" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
{{- end }}
