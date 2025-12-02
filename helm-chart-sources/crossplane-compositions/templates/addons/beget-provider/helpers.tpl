{{- define "addons.begetcmprovider" }}
name: BegetCmProvider
debug: false
path: .
repoURL: https://gitlab.beget.ru/cloud/k8s/charts/capi-provider-beget-controller-manager.git
targetRevision: HEAD
{{- end }}
