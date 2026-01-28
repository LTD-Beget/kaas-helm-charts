{{- define "newaddons.crossplaneFunctions" -}}
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
                        - '--max-reconcile-rate=500'
            {{ if and $systemEnabled $crossplaneReady }}
                      resources:
                        requests: { cpu: "6", memory: "8Mi" }
                        limits:   { cpu: "16", memory: "32Gi" }
            {{ end }}
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
            {{ if and $systemEnabled $crossplaneReady }}
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane-prov
                      operator: Exists
                  nodeSelector:
                    node-role.kubernetes.io/crossplane-prov: ''
            {{ end }}
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
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
            {{ if and $systemEnabled $crossplaneReady }}
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists	
                  nodeSelector:
                    node-role.kubernetes.io/crossplane: ''
            {{ end }}
      far:
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
            {{ if and $systemEnabled $crossplaneReady }}
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists
                  nodeSelector:
                    node-role.kubernetes.io/crossplane: ''
            {{ end }}
      fer:
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
            {{ if and $systemEnabled $crossplaneReady }}
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists
                  nodeSelector:
                    node-role.kubernetes.io/crossplane: ''
            {{ end }}
      fgt:
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
            {{ if and $systemEnabled $crossplaneReady }}
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists
                  nodeSelector:
                    node-role.kubernetes.io/crossplane: ''
                  containers:
                    - name: package-runtime
                      resources:
                        requests: { cpu: "1", memory: "1Gi" }
                        limits:   { cpu: "6", memory: "4Gi" }
              replicas: 5
            {{ else }}
                  containers:
                    - name: package-runtime
                      resources:
                        requests: { cpu: "400m", memory: "128Mi" }
                        limits:   { cpu: "2", memory: "500Mi" }
            {{ end }}
      fec:
        runtimeConfig:
          deploymentTemplate:
            spec:
              template:
                spec:
                  tolerations:
                    - key: node-role.kubernetes.io/control-plane
                      operator: Exists
                      effect: NoSchedule
                    - key: node-role.kubernetes.io/master
                      operator: Exists
                      effect: NoSchedule
            {{ if and $systemEnabled $crossplaneReady }}
                    - effect: NoSchedule
                      key: node-role.kubernetes.io/crossplane	
                      operator: Exists
                  nodeSelector:
                    node-role.kubernetes.io/crossplane: ''
            {{ end }}
  ` }}
{{- end -}}
