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
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  containers:
                    - name: package-runtime
                      args:
                        - --poll=5s
                        - --enable-watches
                        - --poll-jitter-percentage=1
  {{- if and $systemEnabled $crossplaneReady }}
                      resources:
                        requests: { cpu: "2", memory: "768Mi" }
                        limits:   { cpu: "8", memory: "8Gi" }
                  nodeSelector:
                      node-role.kubernetes.io/crossplane: ''
                  tolerations:
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists	
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- else }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- end }}
        monitoring:
        {{ if $infraVMOperatorReady }}
          enabled: true
        {{ end }}
          type: VictoriaMetrics
          secureService:
            enabled: true
            port: 11052
            issuer:
              name: selfsigned-cluster-issuer

      fpat:
        # package: dmkolbin/crossplane-function-patch-and-transform
        # tag: v0.8.2
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  containers:
                    - name: package-runtime
  {{- if and $systemEnabled $crossplaneReady }}
                  nodeSelector:
                      node-role.kubernetes.io/crossplane: ''
                  tolerations:
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists	
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- else }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- end }}
        monitoring:
        {{ if $infraVMOperatorReady }}
          enabled: true
        {{ end }}
          type: VictoriaMetrics
          secureService:
            enabled: true
            port: 11053
            issuer:
              name: selfsigned-cluster-issuer
      far:
        # package: dmkolbin/crossplane-function-auto-ready
        # tag: v0.4.2
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  containers:
                    - name: package-runtime
  {{- if and $systemEnabled $crossplaneReady }}
                  nodeSelector:
                      node-role.kubernetes.io/crossplane: ''
                  tolerations:
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists	
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- else }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- end }}
      fer:
        # package: dmkolbin/crossplane-function-extra-resources
        # tag: v0.1.0
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  containers:
                    - name: package-runtime
  {{- if and $systemEnabled $crossplaneReady }}
                  nodeSelector:
                      node-role.kubernetes.io/crossplane: ''
                  tolerations:
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists	
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- else }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- end }}
      fgt:
        # package: dmkolbin/crossplane-function-go-templating
        # tag: v0.10.0
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
  {{- if and $systemEnabled $crossplaneReady }}
                  nodeSelector:
                      node-role.kubernetes.io/crossplane: ''
                  tolerations:
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists	
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
                  containers:
                    - name: package-runtime
                      resources:
                        requests: { cpu: "1", memory: "1Gi" }
                        limits:   { cpu: "6", memory: "4Gi" }
              replicas: 5
  {{- else }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
                  containers:
                    - name: package-runtime
                      resources:
                        requests: { cpu: "400m", memory: "128Mi" }
                        limits:   { cpu: "2", memory: "500Mi" }
  {{- end }}
      fec:
        # package: dmkolbin/crossplane-function-environment-configs
        # tag: v0.4.0
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
  {{- if and $systemEnabled $crossplaneReady }}
                  nodeSelector:
                      node-role.kubernetes.io/crossplane: ''
                  tolerations:
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists	
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- else }}
                  containers:
                    - name: package-runtime
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
  {{- end }}
  ` }}
{{- end -}}
