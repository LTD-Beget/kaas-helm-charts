{{- define "addons.helminserter" }}
name: HelmInserter
debug: false
path: .
repoURL: https://gitlab.beget.ru/cloud/k8s/charts/helm-inserter.git
targetRevision: HEAD
{{- end }}
