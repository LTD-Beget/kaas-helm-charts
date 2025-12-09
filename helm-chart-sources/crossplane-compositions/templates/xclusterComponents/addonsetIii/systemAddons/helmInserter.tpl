{{- define "xclusterComponents.addonsetIii.helmInserter" -}}
  {{- printf `
helmInserter:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsHelmInserter
  finalizerDisabled: true
  namespace: beget-argocd
  version: v1alpha1
  values:
    resources:
      namespaceCustomer:
        apiVersion: v1
        kind: Namespace
        metadata:
          name: {{ $systemNamespace }}
          labels:
            in-cloud.io/clusterName: {{ $clusterName }}
      appProjectCustomer:
        apiVersion: argoproj.io/v1alpha1
        kind: AppProject
        metadata:
          annotations:
            argocd.argoproj.io/compare-options: "IgnoreExtraneous"
            argocd.argoproj.io/tracking-id: {{ $trackingID }}
          name: {{ $xcluster }}
          namespace: beget-argocd
        spec:
          clusterResourceWhitelist:
          - group: '*'
            kind: '*'
          destinations:
          - namespace: {{ $systemNamespace }}
            server: '*'
          - namespace: '*'
            name: {{ $clusterName }}
          sourceRepos:
          - '*'
          sourceNamespaces:
          - '*'
      clusterIssuerEtcdCa:
        apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: etcd-ca
        spec:
          ca:
            secretName: {{ $clusterName }}-etcd
  ` }}
{{- end -}}
