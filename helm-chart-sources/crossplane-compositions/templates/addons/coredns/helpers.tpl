{{- define "addons.coredns" }}
name: Coredns
debug: false
path: helm-chart-sources/coredns
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: feat/monitoring
pluginName: kustomize-helm-with-values
default: |
  coredns:
    isClusterService: true
    serviceType: ClusterIP
    priorityClassName: system-cluster-critical
    prometheus:
      service:
        enabled: true
    replicaCount: 3
    resources:
      limits:
        cpu: 200m
        memory: 256Mi
      requests:
        cpu: 100m
    rollingUpdate:
      maxSurge: 35%
    securityContext:
      runAsNonRoot: false
      readOnlyRootFilesystem: true
      runAsUser: 0
    serviceAccount:
      create: true
      name: coredns
    affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
              - coredns
            - key: app.kubernetes.io/instance
              operator: In
              values:
              - coredns
          topologyKey: kubernetes.io/hostname
        weight: 100
immutable: |
  coredns:
    service:
      clusterIP: 29.64.0.10
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
            parameters: . 8.8.8.8
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
{{- end }}
