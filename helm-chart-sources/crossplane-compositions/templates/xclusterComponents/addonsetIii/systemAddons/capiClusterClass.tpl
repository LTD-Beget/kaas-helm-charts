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
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/registry-1-docker-io'
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://registry-1.docker.io"
                    args:
                      skip_verify: false
                      priority: 2
              registry-1.docker.io:
                server: https://registry-1.docker.io
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/registry-1-docker-io"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://registry-1.docker.io"
                    args:
                      skip_verify: false
                      priority: 2
              europe-docker.pkg.dev:
                server: https://europe-docker.pkg.dev
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/europe-docker-pkg-dev"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://europe-docker.pkg.dev"
                    args:
                      skip_verify: false
                      priority: 2
              gcr.io:
                server: https://gcr.io
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/gcr-io"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://gcr.io"
                    args:
                      skip_verify: false
                      priority: 2
              ghcr.io:
                server: https://ghcr.io
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/ghcr-io"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://ghcr.io"
                    args:
                      skip_verify: false
                      priority: 2
              mirror.gcr.io:
                server: https://mirror.gcr.io
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/mirror-gcr-io"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://mirror.gcr.io"
                    args:
                      skip_verify: false
                      priority: 2
              public.ecr.aws:
                server: https://public.ecr.aws
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/public-ecr-aws"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://public.ecr.aws"
                    args:
                      skip_verify: false
                      priority: 2
              quay.io:
                server: https://quay.io
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/quay-io"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://quay.io"
                    args:
                      skip_verify: false
                      priority: 2
              registry.k8s.io:
                server: https://registry.k8s.io
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/registry-k8s-io"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://registry.k8s.io"
                    args:
                      skip_verify: false
                      priority: 2
              xpkg.crossplane.io:
                server: https://xpkg.crossplane.io
                mirrors:
                  - mirror: '{{ "{{` }} {{ printf ` .containerd_mirror_url }}" }}/repository/xpkg-crossplane-io"
                    args:
                      skip_verify: false
                      ca: "/etc/kubernetes/pki/ca-oidc.crt"
                      priority: 1
                  - mirror: "https://xpkg.crossplane.io"
                    args:
                      skip_verify: false
                      priority: 2
  ` }}
{{- end -}}
