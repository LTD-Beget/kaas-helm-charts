{{- define "xclusterComponents.addonsetIii.clickhouseVmagentAgregator" -}}
  {{- printf `
clickhouseVmagentAgregator:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsClickhouseVmagentAgregator
  namespace: beget-clickhouse-vmstorage
  version: v1alpha1
  releaseName: vmagent-agregator
  dependsOn:
    - vmOperator
  values:
    victoria-metrics-k8s-stack:
      fullnameOverride: "vmagent-agregator"
      vmagent:
        spec:
          replicaCount: 1
          selectAllByDefault: false
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
            # - name: rbac-proxy
            #   image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
            #   args:
            #     - --secure-listen-address=0.0.0.0:11043
            #     - --upstream=http://127.0.0.1:8429
            #     - --tls-cert-file=/app/config/metrics/tls/tls.crt
            #     - --tls-private-key-file=/app/config/metrics/tls/tls.key
            #     - --v=2
            #   ports:
            #     - name: https-metrics
            #       containerPort: 11043
            #       protocol: TCP
            #   resources:
            #     requests:
            #       memory: "32Mi"
            #       cpu: "10m"
            #     limits:
            #       memory: "64Mi"
            #       cpu: "50m"
            #   volumeMounts:
            #     - name: rbac-proxy-tls
            #       mountPath: /app/config/metrics/tls
            #       readOnly: true
          tolerations:
            - key: "node-role.kubernetes.io/control-plane"
              operator: "Exists"
              effect: "NoSchedule"
            - key: "node-role.kubernetes.io/master"
              operator: "Exists"
              effect: "NoSchedule"
          managedMetadata:
            labels:
              app: vmagent-agregator
              incloud-metrics: "infra"
          serviceSpec:
            metadata:
              name: vmagent-agregator
            spec:
              type: ClusterIP
              useAsDefault: true
          extraArgs:
            tls: "true"
            tlsCertFile: "/tls/tls.crt"
            tlsKeyFile: "/tls/tls.key"
            remoteWrite.forcePromProto: "true"
          volumeMounts:
            - name: trusted-ca-certs
              mountPath: /etc/ssl/certs
              readOnly: true
            - name: vmagent-agregator-tls
              mountPath: /tls
              readOnly: true
          volumes:
            - name: trusted-ca-certs
              configMap:
                name: ca
            - name: vmagent-agregator-tls
              secret:
                secretName: vmagent-agregator-tls
            # - name: rbac-proxy-tls
            #   secret:
            #     defaultMode: 420
            #     secretName: vmagent-monitoring-svc-tls
          remoteWrite:
            # Отправка агрегированных данных в clickhouse
            # TODO: Добавить поддержку https
            - url: http://clickhouse-vmstorage-carbon.beget-clickhouse-vmstorage.svc:2006/api/v1/write
            - url: http://clickhouse-vmstorage.beget-clickhouse-vmstorage.svc:9363/promrw
              basicAuth:
                username:
                  name: clickhouse-credentials
                  key: username
                password:
                  name: clickhouse-credentials
                  key: password

              streamAggrConfig:
                keepInput: false
                dropInput: true

                # Исключение лишних лейблов
                dropInputLabels: ["pod_uid", "container_id", "id", "image_id"]

                rules:
                  # Nodes: CPU
                  - match: 'node_cpu_seconds_total{mode="idle"}'
                    interval: 1m
                    by: ["cluster", "node"] # add nodegroup label
                    outputs: ["rate_avg"]   # streaming aggregation outputs https://docs.victoriametrics.com/victoriametrics/stream-aggregation/configuration/

                  # Nodes: RAM (достаточно MemAvailable и MemTotal)
                  - match: 'node_memory_MemAvailable_bytes'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["avg"]

                  - match: 'node_memory_MemTotal_bytes'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["last"]

                  # Nodes: Disk (size/available)
                  - match: 'node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["avg"]

                  - match: 'node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}'
                    interval: 1m
                    by: ["cluster", "node"]
                    outputs: ["last"]

                  # Pods: CPU/RAM per pod
                  - match: 'container_cpu_usage_seconds_total{container!="",image!=""}'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "node"]
                    outputs: ["rate_sum"]

                  - match: 'container_memory_working_set_bytes{container!="",image!=""}'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "node"]
                    outputs: ["avg"]

                  # Pods: restarts/status (kube-state-metrics)
                  - match: 'kube_pod_container_status_restarts_total'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "container"]
                    outputs: ["last"]

                  # статус по фазам (Running/Pending/Failed/...)
                  - match: 'kube_pod_status_phase'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "phase"]
                    outputs: ["last"]

                  - match: 'kube_pod_info'
                    interval: 1m
                    by: ["cluster", "namespace", "pod", "node"]
                    outputs: ["last"]

    monitoring:
      enabled: false

    tls:
      vmAgentAgregator:
        enabled: true
        issuer:
          kind: ClusterIssuer
          name: selfsigned-cluster-issuer
        certificate:
          name: vmagent-agregator-tls
          secretName: vmagent-agregator-tls
          commonName: vmagent-agregator
          dnsNames:
            - "vmagent-agregator"
            - "vmagent-agregator.beget-clickhouse-vmstorage"
            - "vmagent-agregator.beget-clickhouse-vmstorage.svc"
          ipAddresses:
            - 127.0.0.1
            - {{ $systemVmGatewayVip }}
  ` }}
{{- end -}}
