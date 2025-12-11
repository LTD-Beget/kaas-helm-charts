{{- define "addons.crossplane" }}
name: Crossplane
debug: false
path: helm-chart-sources/crossplane
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
{{- $addonValue := dig "composite" "addons" "crossplane" .Values.composite.addons.common (.Values | toYaml | fromYaml) }}
targetRevision: {{ $addonValue.targetRevision | default "HEAD" }}
default: |
  crossplane:
    args:
      - '--enable-realtime-compositions'
      - '--enable-composition-webhook-schema-validation'
      - '--enable-composition-functions'
      - '--enable-usages'
      - '--poll-interval=5s'
      - '--sync-interval=1m'
      - '--max-reconcile-rate=20'
    extraObjects:
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: crossplane-namespace-admin
        rules:
          - apiGroups:
              - ''
            resources:
              - namespaces
            verbs:
              - '*'
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: crossplane-namespace-admin
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: crossplane-namespace-admin
        subjects:
          - kind: ServiceAccount
            name: crossplane
            namespace: beget-crossplane
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: crossplane-xclusters-admin
        rules:
          - apiGroups:
              - cluster.x-k8s.io
            resources:
              - xclusters
              - clusterclaims
            verbs:
              - '*'
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: crossplane-xclusters-admin
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: crossplane-xclusters-admin
        subjects:
          - kind: ServiceAccount
            name: crossplane
            namespace: beget-crossplane
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: crossplane-clusters-admin
        rules:
          - apiGroups:
              - cluster.x-k8s.io
            resources:
              - clusters
            verbs:
              - '*'
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: crossplane-argocd-admin
        rules:
          - apiGroups:
              - argoproj.io
            resources:
              - '*'
            verbs:
              - '*'
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: crossplane-argocd-admin
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: crossplane-argocd-admin
        subjects:
          - kind: ServiceAccount
            name: crossplane
            namespace: beget-crossplane
      - apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: crossplane-cluster-admin
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: cluster-admin
        subjects:
          - kind: ServiceAccount
            name: crossplane
            namespace: beget-crossplane
    hostNetwork: false
    metrics:
      enabled: true
      port: 8080
    rbacManager:
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    resourcesCrossplane:
      limits:
        cpu: 750m
        memory: 2048Mi
    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
{{- end }}
