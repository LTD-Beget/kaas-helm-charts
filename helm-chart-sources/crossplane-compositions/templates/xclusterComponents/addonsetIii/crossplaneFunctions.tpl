{{- define "xclusterComponents.addonsetIii.crossplaneFunctions" -}}
  {{- printf `
crossplaneFunctions:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCrossplaneFunctions
  finalizerDisabled: false
  namespace: beget-crossplane
  version: v1alpha1
  dependsOn:
    - istioGW
  values:
    components:
      kubernetes:
        # package: dmkolbin/crossplane-provider-kubernetes
        # tag: v1.0.1
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
  {{- if $systemEnabled }}
                      resources:
                        requests: { cpu: "2", memory: "768Mi" }
                        limits:   { cpu: "4", memory: "2Gi" }
  {{- end }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
      fpat:
        # package: dmkolbin/crossplane-function-patch-and-transform
        # tag: v0.8.2
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
        # package: dmkolbin/crossplane-function-auto-ready
        # tag: v0.4.2
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
        # package: dmkolbin/crossplane-function-extra-resources
        # tag: v0.1.0
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
        # package: dmkolbin/crossplane-function-go-templating
        # tag: v0.10.0
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
  {{- if $systemEnabled }}
                      resources:
                        requests: { cpu: "700m", memory: "128Mi" }
                        limits:   { cpu: "1", memory: "200Mi" }
                  replicas: 3
  {{- end }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
      fec:
        # package: dmkolbin/crossplane-function-environment-configs
        # tag: v0.4.0
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
  ` }}
{{- end -}}