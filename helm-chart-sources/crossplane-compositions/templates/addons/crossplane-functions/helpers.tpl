{{- define "addons.crossplanefunctions" }}
name: CrossplaneFunctions
debug: false
path: helm-chart-sources/crossplane-functions
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/crossplane
default: |
  components:
    kubernetes:
      runtimeConfig:
        deploymentTemplate:
          spec:
            selector:
              matchLabels:
                pkg.crossplane.io/provider: provider-kubernetes
            template:
              spec:
                containers:
                  - name: package-runtime
                    args:
                      - --poll=5s
                      - --enable-watches
                      - --poll-jitter-percentage=1
                tolerations:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
                    effect: NoSchedule
                  - key: node-role.kubernetes.io/master
                    operator: Exists
                    effect: NoSchedule
    fpat:
      runtimeConfig:
        deploymentTemplate:
          spec:
            selector:
              matchLabels:
                pkg.crossplane.io/function: function-patch-and-transform
            template:
              spec:
                containers:
                  - name: package-runtime
                tolerations:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
                    effect: NoSchedule
                  - key: node-role.kubernetes.io/master
                    operator: Exists
                    effect: NoSchedule
    far:
      runtimeConfig:
        deploymentTemplate:
          spec:
            selector:
              matchLabels:
                pkg.crossplane.io/function: function-auto-ready 
            template:
              spec:
                containers:
                  - name: package-runtime
                tolerations:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
                    effect: NoSchedule
                  - key: node-role.kubernetes.io/master
                    operator: Exists
                    effect: NoSchedule
    fer:
      runtimeConfig:
        deploymentTemplate:
          spec:
            selector:
              matchLabels:
                pkg.crossplane.io/function: function-extra-resources
            template:
              spec:
                containers:
                  - name: package-runtime
                tolerations:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
                    effect: NoSchedule
                  - key: node-role.kubernetes.io/master
                    operator: Exists
                    effect: NoSchedule
    fgt:
      runtimeConfig:
        deploymentTemplate:
          spec:
            selector:
              matchLabels:
                pkg.crossplane.io/function: function-go-templating
            template:
              spec:
                containers:
                  - name: package-runtime
                tolerations:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
                    effect: NoSchedule
                  - key: node-role.kubernetes.io/master
                    operator: Exists
                    effect: NoSchedule
    fec:
      runtimeConfig:
        deploymentTemplate:
          spec:
            selector:
              matchLabels:
                pkg.crossplane.io/function: function-environment-configs
            template:
              spec:
                containers:
                  - name: package-runtime
                tolerations:
                  - key: node-role.kubernetes.io/control-plane
                    operator: Exists
                    effect: NoSchedule
                  - key: node-role.kubernetes.io/master
                    operator: Exists
                    effect: NoSchedule
manifest:
  spec:
    syncPolicy:
      retry:
        limit: 100
        backoff:
          duration: 5s
          factor: 1
          maxDuration: 3m0s
{{- end }}
