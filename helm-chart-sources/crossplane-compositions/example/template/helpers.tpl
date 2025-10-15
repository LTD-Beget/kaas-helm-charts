{{- define "addons.template" }}
name: Template
debug: false
path: helm-chart-sources/template
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
default: |
  template:
immutable: |
  template:
{{- end }}
