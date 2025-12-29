{{- define "xclusterComponents.addonsetIii.dockerRegistryCache" -}}
  {{- printf `
dockerRegistryCache:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsDockerRegistryCache
  namespace: beget-container-registry
  version: v1alpha1
  values:
    internalTLS:
      {{- if $certManagerReady }}
      certSource: certmanager
      {{- end }}
      certmanager:
        existingIssuer:
          kind: ClusterIssuer
          name: selfsigned-cluster-issuer

    expose:
      {{- if $istioBaseReady }}
      enabled: true
      {{- end }}
      resourceType: istio
      istio:
        gateway:
          enabled: false
          name: beget-istio-gw/default

    default:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"

      serviceAccount:
        create: true

      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 400m
          memory: 512Mi

      metrics:
        enabled: true
        secureEndpoint: true
        scrape:
        {{- if $infraVMOperatorReady }}
          enabled: true
        {{- end }}

      config:
        log:
          level: info

    proxies:
      registry-1-docker-io:
        enabled: true
        config:
          proxy:
            remoteurl: https://registry-1.docker.io

      europe-docker-pkg-dev:
        enabled: true
        config:
          proxy:
            remoteurl: https://europe-docker.pkg.dev

      gcr-io:
        enabled: true
        config:
          proxy:
            remoteurl: https://gcr.io

      ghcr-io:
        enabled: true
        config:
          proxy:
            remoteurl: https://ghcr.io

      mirror-gcr-io:
        enabled: true
        config:
          proxy:
            remoteurl: https://mirror.gcr.io

      public-ecr-aws:
        enabled: true
        config:
          proxy:
            remoteurl: https://public.ecr.aws

      quay-io:
        enabled: true
        config:
          proxy:
            remoteurl: https://quay.io

      registry-k8s-io:
        enabled: true
        config:
          proxy:
            remoteurl: https://registry.k8s.io

      xpkg-crossplane-io:
        enabled: true
        config:
          proxy:
            remoteurl: https://xpkg.crossplane.io
  ` }}
{{- end -}}
