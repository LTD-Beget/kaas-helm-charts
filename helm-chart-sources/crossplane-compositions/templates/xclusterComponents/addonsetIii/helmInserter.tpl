{{- define "xclusterComponents.addonsetIii.helmInserterTest" -}}
  {{- printf `
helmInserterTest:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsHelmInserter
  namespace: beget-argocd
  version: v1alpha1
  releaseName: namespace-test
  values:
    resources:
      namespaceTest:
        apiVersion: v1
        kind: Namespace
        metadata:
          name: test-ns
  ` }}
{{- end -}}
