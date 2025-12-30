{{- define "xclusterComponents.addonsetIii.crossplaneXcluster" -}}
  {{- printf `
crossplaneXcluster:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplaneXcluster
  namespace: beget-crossplane
  version: v1alpha1
  values:
    composition:
      cluster:
        spec:
          clusterNetwork:
            apiServerPort: 6443
          topology:
            class: capi-cluster-class-cluster-template
            classNamespace: bcloud-capi
            controlPlane:
              replicas: 3
            version: v1.30.4
      coreProject:
        metadata:
          namespace: beget-argocd
      istioGwVip: {{ $systemIstioGwVip }}
      systemKubeApiVip: {{ $clusterHost }}
  ` }}
{{- end -}}
