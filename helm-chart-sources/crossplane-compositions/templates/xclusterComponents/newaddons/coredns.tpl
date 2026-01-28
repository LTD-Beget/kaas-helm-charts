{{- define "newaddons.coredns" -}}
  {{- printf `
coredns:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCoredns
  finalizerDisabled: false
  namespace: beget-coredns
  version: v1alpha1
  dependsOn: 
    - istioGW
  pluginName: helm-with-values
  values:
  {{ if $certManagerReady }}
    argocdPlugins:
      kustomize: true
  {{ end }}
    coredns:
  {{ if $corednsReady }}
      replicaCount: {{ $controlPlaneReplicas }}
  {{ else  }}
      replicaCount: 1
  {{ end }}
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: coredns
                  app.kubernetes.io/instance: coredns
              topologyKey: kubernetes.io/hostname
  {{ if $systemEnabled }}
      servers:
        - zones:
            - zone: cluster.local.
          port: 53
          plugins:
            - name: kubernetes
              parameters: cluster.local in-addr.arpa ip6.arpa
              configBlock: |-
                pods verified
                fallthrough in-addr.arpa ip6.arpa
                ttl 30
            - name: transfer
              configBlock: |-
                to *
            - name: loop
            - name: reload
            - name: errors
            - name: ready
            - name: loadbalance
              parameter: round_robin
            - name: forward
              parameters: . /etc/resolv.conf
            - name: cache
              parameters: 30
            - name: prometheus
              parameters: 0.0.0.0:9153
            - name: log
              configBlock: |-
                class all
            - name: health
              configBlock: |-
                lameduck 5s
        - zones:
            - zone: .
          port: 53
          plugins:
            - name: loop
            - name: reload
            - name: errors
            - name: ready
            - name: loadbalance
              parameter: round_robin
            - name: forward
              parameters: . {{ $argsCorednsRoot }}
              configBlock: |-
                force_tcp
            - name: cache
              parameters: 30
            - name: prometheus
              parameters: 0.0.0.0:9153
            - name: log
              configBlock: |-
                class all
            - name: health
              configBlock: |-
                lameduck 5s
  {{ end }}
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
      {{ if $certManagerReady }}
        enabled: true
      {{ end }}
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
