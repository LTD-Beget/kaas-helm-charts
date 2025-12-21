{{- define "xclusterComponents.addonsetIii.vmAgent" -}}
  {{- printf `
vmAgent:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVictoriaMetricsAgent
  namespace: beget-vmagent
  version: v1alpha1
  releaseName: vmagent
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-k8s-stack:
      fullnameOverride: "vmagent"
      vmagent:
        spec:
          serviceScrapeSpec:
            selector:
              matchLabels:
                monitoring.in-cloud.io/service: vmagent
            endpoints:
              - port: https-metrics
                path: /metrics
                scheme: HTTPS
                bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
                tlsConfig:
                  serverName: vmagent-monitoring
            jobLabel: vmagent
          containers:
            - name: config-reloader
              requests:
                cpu: 100m
                memory: 128Mi
              limits:
                cpu: 100m
                memory: 200Mi
              securityContext:
                runAsNonRoot: true
                runAsUser: 65534
            - name: vmagent
              securityContext:
                readOnlyRootFilesystem: true
                allowPrivilegeEscalation: false
            - name: rbac-proxy
              image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
              args:
                - --secure-listen-address=0.0.0.0:11043
                - --upstream=http://127.0.0.1:8429
                - --tls-cert-file=/app/config/metrics/tls/tls.crt
                - --tls-private-key-file=/app/config/metrics/tls/tls.key
                - --v=2
              ports:
                - name: https-metrics
                  containerPort: 11043
                  protocol: TCP
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
          tolerations:
            - key: "node-role.kubernetes.io/control-plane"
              operator: "Exists"
              effect: "NoSchedule"
            - key: "node-role.kubernetes.io/master"
              operator: "Exists"
              effect: "NoSchedule"
          podMetadata:
            labels:
              app: vmagent
              incloud-metrics: "infra"
          remoteWrite:
            - url: {{ $remoteWriteUrlVmAgent }}
              tlsConfig:
            {{ if $systemEnabled }}
                caFile: /etc/ssl/certs/ca.crt
            {{ else }}
                caFile: /tls/cabundle/ca.crt
            {{ end }}
          volumeMounts:
            {{ if not $systemEnabled }}
            - name: ca-bundle
              mountPath: /tls/cabundle
              readOnly: true
            {{ end }}
            - name: trusted-ca-certs
              mountPath: /etc/ssl/certs
              readOnly: true
          volumes:
            - name: trusted-ca-certs
              configMap:
                name: ca
            - name: rbac-proxy-tls
              secret:
                defaultMode: 420
                secretName: vmagent-monitoring-svc-tls
            {{ if not $systemEnabled }}
            - name: ca-bundle
              configMap:
                name: system-ca-bundle
            {{ end }}
          serviceScrapeNamespaceSelector:
            matchExpressions:
              - operator: In
                key: "in-cloud.io/clusterName"
                values: [{{ $clusterName }}]
          podScrapeNamespaceSelector:
            matchExpressions:
              - operator: In
                key: "in-cloud.io/clusterName"
                values: [{{ $clusterName }}]
          nodeScrapeNamespaceSelector:
            matchExpressions:
              - operator: In
                key: "in-cloud.io/clusterName"
                values: [{{ $clusterName }}]
          staticScrapeNamespaceSelector:
            matchExpressions:
              - operator: In
                key: "in-cloud.io/clusterName"
                values: [{{ $clusterName }}]
          probeNamespaceSelector:
            matchExpressions:
              - operator: In
                key: "incloud.io/clusterName"
                values: [{{ $clusterName }}]
          externalLabels:
            cluster_full_name: {{ printf "%%s-%%s" $customer $clusterName }}
            remotewrite_cluster: {{ printf "%%s-%%s" $customer $clusterName }}
          extraArgs:
            remoteWrite.label: remotewrite_cluster={{ printf "%%s-%%s" $customer $clusterName }}
            remoteWrite.tlsInsecureSkipVerify: "false"
      kubeControllerManager:
        enabled: true
        vmScrape:
          spec:
            endpoints:
              - port: "http-metrics"
                scheme: "https"
                bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
                tlsConfig:
                  caFile: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                  serverName: {{ printf "%%s-controller-manager" $clusterName }}
      kubeScheduler:
        enabled: true
        vmScrape:
          spec:
            endpoints:
              - port: "http-metrics"
                scheme: "https"
                bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
                tlsConfig:
                  caFile: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
                  serverName: {{ printf "%%s-scheduler" $clusterName }}
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
  ` }}
{{- end -}}
