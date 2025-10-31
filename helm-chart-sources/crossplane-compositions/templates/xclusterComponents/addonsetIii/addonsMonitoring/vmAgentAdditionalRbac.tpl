{{- define "xclusterComponents.addonsetIii.vmAgentAdditionalRbac" -}}
  {{- printf `
helmInserterVMAgentAdditionalRbac:
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
          name: non-resource-metrics-url
        rules:
          - nonResourceURLs:
              - "/metrics"
              - "/grafana/metrics"
            verbs:
              - get

      metricsClusterRoleBinding:
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: metrics
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: ClusterRole
          name: non-resource-metrics-url
        subjects:
          - kind: ServiceAccount
            name: vmagent-vmagent
            namespace: beget-vmagent
  ` }}
{{- end -}}
