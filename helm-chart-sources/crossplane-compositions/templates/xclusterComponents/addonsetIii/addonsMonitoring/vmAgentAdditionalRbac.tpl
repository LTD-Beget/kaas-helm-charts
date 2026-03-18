{{- define "xclusterComponents.addonsetIii.helmInsVMAgentAddRbac" -}}
  {{- printf `
helmInsVMAgentAddRbac:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsHelmInserter
  namespace: beget-vmagent
  version: v1alpha1
  releaseName: vmagent-additional
  values:
    resources:
      tokenreviewClusterRole:
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: kube-rbac-proxy-tokenreview
        rules:
          - apiGroups:
              - authentication.k8s.io
            resources:
              - tokenreviews
            verbs:
              - create
          - apiGroups:
              - authorization.k8s.io
            resources:
              - subjectaccessreviews
            verbs:
              - create

      metricsClusterRole:
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
          name: vmagent-metrics
        rules:
          - nonResourceURLs:
              - "/grafana/metrics"
            verbs:
              - get
          - apiGroups:
              - ""
            resources:
              - "services/kube-state-metrics"
              - "services/client-kube-state-metrics"
              - "services/prometheus-node-exporter"
            resourceNames:
              - "kube-state-metrics"
              - "client-kube-state-metrics"
              - "prometheus-node-exporter"
            verbs:
              - "get"

      metricsClusterRoleBinding:
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: vmagent-metrics
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: vmagent-metrics
        subjects:
          - kind: ServiceAccount
            name: vmagent-vmagent
            namespace: beget-vmagent
  ` }}
{{- end -}}
