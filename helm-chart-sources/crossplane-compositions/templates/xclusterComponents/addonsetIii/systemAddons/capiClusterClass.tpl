{{- define "xclusterComponents.addonsetIii.capiClusterClass" -}}
  {{- printf `
capiClusterClass:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCapiClusterClass
  namespace: bcloud-capi
  version: v1alpha1
  dependsOn:
    - capi
  values:
    inCloud:
      serviceAccount:
        name: capi
    capi:
      k8s:
        containerRuntime:
          mirrors:
            repos:
              docker.io:
                server: https://docker.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/registry-1-docker-io"
                  - "https://registry-1.docker.io"
              registry-1.docker.io:
                server: https://registry-1.docker.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/registry-1-docker-io"
                  - "https://registry-1.docker.io"
              europe-docker.pkg.dev:
                server: https://europe-docker.pkg.dev
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/europe-docker-pkg-dev"
                  - "https://europe-docker.pkg.dev"
              gcr.io:
                server: https://gcr.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/gcr-io"
                  - "https://gcr.io"
              ghcr.io:
                server: https://ghcr.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/ghcr-io"
                  - "https://ghcr.io"
              mirror.gcr.io:
                server: https://mirror.gcr.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/mirror-gcr-io"
                  - "https://mirror.gcr.io"
              public.ecr.aws:
                server: https://public.ecr.aws
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/public-ecr-aws"
                  - "https://public.ecr.aws"
              quay.io:
                server: https://quay.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/quay-io"
                  - "https://quay.io"
              registry.k8s.io:
                server: https://registry.k8s.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/registry-k8s-io"
                  - "https://registry.k8s.io"
              xpkg.crossplane.io:
                server: https://xpkg.crossplane.io
                mirrors:
                  - "https://{{ $systemClusterVip }}/repository/xpkg-crossplane-io"
                  - "https://xpkg.crossplane.io"
  ` }}
{{- end -}}
