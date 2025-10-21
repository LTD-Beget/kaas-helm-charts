{{- define "addons.crossplane" }}
name: Crossplane
debug: false
chart: crossplane
repoURL: https://charts.crossplane.io/stable
targetRevision: 1.20.1
default: |
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
  resourcesCrossplane:
    limits:
      cpu: 750m
      memory: 2048Mi
{{- end }}
