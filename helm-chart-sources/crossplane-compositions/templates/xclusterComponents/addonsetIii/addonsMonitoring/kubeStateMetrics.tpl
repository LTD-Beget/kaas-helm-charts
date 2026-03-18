{{- define "xclusterComponents.addonsetIii.kubeStateMetrics" -}}
  {{- printf `
kubeStateMetrics:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsKubeStateMetrics
  namespace: beget-kube-state-metrics
  version: v1alpha1
  dependsOn:
    - vmOperator
  pluginName: helm-with-values
  values:
    kube-state-metrics:
      customResourceState:
        enabled: true
        config:
          kind: CustomResourceStateMetrics
          spec:
            resources:
              - groupVersionKind:
                  group: cluster.x-k8s.io
                  version: v1beta2
                  kind: Cluster
                metricNamePrefix: capi_cluster
                labelsFromPath:
                  cluster_name: [metadata, name]
                  cluster_namespace: [metadata, namespace]
                  cluster_hash: [metadata, labels, "xcluster.in-cloud.io/name"]
                metrics:
                  - name: resource_info
                    help: "Cluster inventory info."
                    each:
                      type: Info
                      info:
                        labelsFromPath:
                          topology_class: [spec, topology, classRef, name]
                          topology_class_namespace: [spec, topology, classRef, namespace]
                          kubernetes_version: [spec, topology, version]
                          controlplane_endpoint_host: [spec, controlPlaneEndpoint, host]
                          controlplane_endpoint_port: [spec, controlPlaneEndpoint, port]

                  - name: created_timestamp_seconds
                    help: "Cluster creation timestamp."
                    each:
                      type: Gauge
                      gauge:
                        path: [metadata, creationTimestamp]

                  - name: deleted_timestamp_seconds
                    help: "Cluster deletion timestamp."
                    each:
                      type: Gauge
                      gauge:
                        path: [metadata, deletionTimestamp]
                        nilIsZero: true

                  - name: status_phase
                    help: "Cluster status phase."
                    each:
                      type: StateSet
                      stateSet:
                        labelName: phase
                        path: [status, phase]
                        list:
                          - Pending
                          - Provisioning
                          - Provisioned
                          - Deleting
                          - Failed
                          - Unknown

                  - name: spec_paused
                    help: "Cluster paused flag."
                    each:
                      type: Gauge
                      gauge:
                        path: [spec, paused]
                        nilIsZero: true

                  - name: condition
                    help: "Cluster conditions."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, conditions]
                        labelsFromPath:
                          type: [type]
                        valueFrom: [status]

                  - name: controlplane_desired_replicas
                    help: "Desired control plane replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, controlPlane, desiredReplicas]
                        nilIsZero: true

                  - name: controlplane_replicas
                    help: "Current control plane replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, controlPlane, replicas]
                        nilIsZero: true

                  - name: controlplane_ready_replicas
                    help: "Ready control plane replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, controlPlane, readyReplicas]
                        nilIsZero: true

                  - name: controlplane_available_replicas
                    help: "Available control plane replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, controlPlane, availableReplicas]
                        nilIsZero: true

                  - name: controlplane_uptodate_replicas
                    help: "Up-to-date control plane replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, controlPlane, upToDateReplicas]
                        nilIsZero: true

                  - name: workers_desired_replicas
                    help: "Desired worker replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, workers, desiredReplicas]
                        nilIsZero: true

                  - name: workers_replicas
                    help: "Current worker replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, workers, replicas]
                        nilIsZero: true

                  - name: workers_ready_replicas
                    help: "Ready worker replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, workers, readyReplicas]
                        nilIsZero: true

                  - name: workers_available_replicas
                    help: "Available worker replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, workers, availableReplicas]
                        nilIsZero: true

                  - name: workers_uptodate_replicas
                    help: "Up-to-date worker replicas."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, workers, upToDateReplicas]
                        nilIsZero: true

                  - name: initialization_controlplane_initialized
                    help: "Whether control plane initialization is complete."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, initialization, controlPlaneInitialized]
                        nilIsZero: true

                  - name: initialization_infrastructure_provisioned
                    help: "Whether infrastructure provisioning is complete."
                    each:
                      type: Gauge
                      gauge:
                        path: [status, initialization, infrastructureProvisioned]
                        nilIsZero: true
      rbac:
        extraRules:
          - apiGroups:
              - cluster.x-k8s.io
            resources:
              - clusters
            verbs:
              - list
              - watch
    {{ if $certManagerReady }}
      kubeRBACProxy:
        enabled: true
        image:
          registry: quay.io
          repository: brancz/kube-rbac-proxy
          tag: v0.21.0

        extraArgs:
          - --secure-listen-address=0.0.0.0:8080
          - --upstream=http://127.0.0.1:9080
          - --tls-cert-file=/app/config/metrics/tls/tls.crt
          - --tls-private-key-file=/app/config/metrics/tls/tls.key
          - --v=2

        resources:
          requests:
            memory: "32Mi"
            cpu: "10m"
          limits:
            memory: "64Mi"
            cpu: "50m"

        volumeMounts:
          - name: rbac-proxy-tls
            mountPath: /app/config/metrics/tls
            readOnly: true

      volumes:
        - name: rbac-proxy-tls
          secret:
            defaultMode: 420
            secretName: kube-state-metrics-svc-tls
    {{ end }}
      customLabels:
        # For vmServiceScrape
        # monitoring.in-cloud.io/service: {{ .Release.Name }}
        monitoring.in-cloud.io/service: kube-state-metrics
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
      serviceScrapeConfig:
        metricRelabelConfigs:
          - source_labels: [cluster_namespace, cluster_name]
            separator: "-"
            regex: "(.+)-(.+)"
            target_label: cluster_full_name
            replacement: "$1-$2"
            action: replace
  ` }}
{{- end -}}
