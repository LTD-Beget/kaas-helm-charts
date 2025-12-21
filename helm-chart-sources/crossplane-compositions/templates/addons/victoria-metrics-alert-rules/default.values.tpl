{{- define "addons.victoriametricsalertrules.default.values" -}}
  {{- printf `%s` `
victoria-metrics-k8s-stack:
  global:
    clusterLabel: cluster_full_name
  defaultRules:
    create: true
    additionalRuleLabels:
      cluster_full_name: "{{ $labels.cluster_full_name }}"
      remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
      in-cloud-metrics: "infra"
    labels:
      cluster_full_name: "in-cloud-cluster-name"
      remotewrite_cluster: "in-cloud-cluster-name"
      in-cloud-metrics: "infra"

    rules:
      AlertmanagerMembersInconsistent:
        create: false
      InfoInhibitor:
        create: false
      TooHighGoroutineSchedulingLatency:
        create: false
  # Change severity critical to warning for alerts for test
      etcdMembersDown:
        spec:
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
      etcdHighNumberOfFailedGRPCRequests:
        spec:
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
      KubeContainerWaiting:
        spec:
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical
      KubePodNotReady:
        spec:
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical
      KubeCPUQuotaOvercommit:
        spec:
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical
      CPUThrottlingHigh:
        spec:
          expr: |-
            sum(increase(container_cpu_cfs_throttled_periods_total{container!="", job="kubelet", metrics_path="/metrics/cadvisor", namespace=~"beget.*|kube.*"}[5m])) without (id, metrics_path, name, image, endpoint, job, node)
              /
            sum(increase(container_cpu_cfs_periods_total{job="kubelet", metrics_path="/metrics/cadvisor", namespace=~"beget.*|kube.*"}[5m])) without (id, metrics_path, name, image, endpoint, job, node)
              > ( 25 / 100 )
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical

    groups:
      etcd:
        create: false
      general:
        create: false
      k8sContainerMemoryRss:
        create: false
      k8sContainerMemoryCache:
        create: false
      k8sContainerCpuUsageSecondsTotal:
        create: false
      k8sPodOwner:
        create: false
      k8sContainerResource:
        create: false
      k8sContainerMemoryWorkingSetBytes:
        create: false
      k8sContainerMemorySwap:
        create: false
      kubePrometheusNodeRecording:
        create: false
      kubernetesApps:
        create: true
        targetNamespace: "beget.*|kube.*|default"
      kubernetesResources:
        create: true
      kubernetesStorage:
        create: true
        targetNamespace: ".*"
      kubernetesSystem:
        create: true
      kubernetesSystemKubelet:
        create: true
      kubernetesSystemApiserver:
        create: true
      kubernetesSystemControllerManager:
        create: true
      kubeScheduler:
        create: yes
      kubernetesSystemScheduler:
        create: true
      kubeStateMetrics:
        create: true
      nodeNetwork:
        create: true
      node:
        create: true
      vmagent:
        create: true
      vmsingle:
        create: false
      vmcluster:
        create: true
      vmHealth:
        create: true
      vmoperator:
        create: false
      alertmanager:
        create: true

  additionalVictoriaMetricsMap:
  # Custom alerts
    # blackbox-monitoring-infra:
    #   additionalLabels:
    #     in-cloud-metrics: "infra"
    #   groups:
    coredns:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: coredns
        params:
          extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests
        rules:
        - alert: CoreDNSDown
          annotations:
            description: CoreDNS has disappeared from Prometheus target discovery.
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednsdown
            summary: CoreDNS has disappeared from Prometheus target discovery.
          expr: |
            absent(up{job="coredns-coredns-metrics"} == 1)
          for: 1m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CoreDNSLatencyHigh
          annotations:
            description: "CoreDNS has 99th percentile latency of {{"{{"}} $value {{"}}"}} seconds for server {{"{{"}} $labels.server {{"}}"}} zone {{"{{"}} $labels.zone {{"}}"}} ."
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednslatencyhigh
            summary: CoreDNS is experiencing high 99th percentile latency.
          expr: |
            histogram_quantile(0.99, sum(rate(coredns_dns_request_duration_seconds_bucket{job="coredns-coredns-metrics"}[5m])) without (instance,pod)) > 4
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CoreDNSErrorsHigh
          annotations:
            description: "CoreDNS is returning SERVFAIL for {{"{{"}} $value | humanizePercentage {{"}}"}} of requests."
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednserrorshigh
            summary: CoreDNS is returning SERVFAIL.
          expr: |
            sum without (pod, instance, server, zone, view, rcode, plugin) (rate(coredns_dns_responses_total{job="coredns-coredns-metrics",rcode="SERVFAIL"}[5m]))
              /
            sum without (pod, instance, server, zone, view, rcode, plugin) (rate(coredns_dns_responses_total{job="coredns-coredns-metrics"}[5m])) > 0.03
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CoreDNSErrorsHigh
          annotations:
            description: "CoreDNS is returning SERVFAIL for {{"{{"}} $value | humanizePercentage {{"}}"}} of requests."
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednserrorshigh
            summary: CoreDNS is returning SERVFAIL.
          expr: |
            sum without (pod, instance, server, zone, view, rcode, plugin) (rate(coredns_dns_responses_total{job="coredns-coredns-metrics",rcode="SERVFAIL"}[5m]))
              /
            sum without (pod, instance, server, zone, view, rcode, plugin) (rate(coredns_dns_responses_total{job="coredns-coredns-metrics"}[5m])) > 0.01
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
      - name: coredns_forward
        params:
          extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests
        rules:
        - alert: CoreDNSForwardLatencyHigh
          annotations:
            description: "CoreDNS has 99th percentile latency of {{"{{"}} $value {{"}}"}} seconds forwarding requests to {{"{{"}} $labels.to {{"}}"}}."
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednsforwardlatencyhigh
            summary: CoreDNS is experiencing high latency forwarding requests.
          expr: |
            histogram_quantile(0.99, sum(rate(coredns_forward_request_duration_seconds_bucket{job="coredns-coredns-metrics"}[5m])) without (pod, instance, rcode)) > 4
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CoreDNSForwardErrorsHigh
          annotations:
            description: "CoreDNS is returning SERVFAIL for {{"{{"}} $value | humanizePercentage {{"}}"}} of forward requests to {{"{{"}} $labels.to {{"}}"}}."
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednsforwarderrorshigh
            summary: CoreDNS is returning SERVFAIL for forward requests.
          expr: |
            sum without (pod, instance, rcode) (rate(coredns_forward_responses_total{job="coredns-coredns-metrics",rcode="SERVFAIL"}[5m]))
              /
            sum without (pod, instance, rcode) (rate(coredns_forward_responses_total{job="coredns-coredns-metrics"}[5m])) > 0.03
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CoreDNSForwardErrorsHigh
          annotations:
            description: "CoreDNS is returning SERVFAIL for {{"{{"}} $value | humanizePercentage {{"}}"}} of forward requests to {{"{{"}} $labels.to {{"}}"}}."
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednsforwarderrorshigh
            summary: CoreDNS is returning SERVFAIL for forward requests.
          expr: |
            sum without (pod, instance, rcode) (rate(coredns_forward_responses_total{job="coredns-coredns-metrics",rcode="SERVFAIL"}[5m]))
              /
            sum without (pod, instance, rcode) (rate(coredns_forward_responses_total{job="coredns-coredns-metrics"}[5m])) > 0.01
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CoreDNSForwardHealthcheckFailureCount
          annotations:
            description: "CoreDNS health checks have failed to upstream server {{"{{"}} $labels.to {{"}}"}}."
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednsforwardhealthcheckfailurecount
            summary: CoreDNS health checks have failed to upstream server.
          expr: |
            sum without (pod, instance) (rate(coredns_forward_healthcheck_failures_total{job="coredns-coredns-metrics"}[5m])) > 0
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CoreDNSForwardHealthcheckBrokenCount
          annotations:
            description: CoreDNS health checks have failed for all upstream servers.
            runbook_url: https://github.com/povilasv/coredns-mixin/tree/master/runbook.md#alert-name-corednsforwardhealthcheckbrokencount
            summary: CoreDNS health checks have failed for all upstream servers.
          expr: |
            sum without (pod, instance) (rate(coredns_forward_healthcheck_broken_total{job="coredns-coredns-metrics"}[5m])) > 0
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
    cert-manager:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: cert-manager
        params:
          extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests
        rules:
        - alert: CertManagerAbsent
          annotations:
            description: New certificates will not be able to be minted, and existing ones
              can't be renewed until cert-manager is back.
            runbook_url: https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagerabsent
            summary: Cert Manager has disappeared from Prometheus service discovery.
          expr: absent(up{job="cert-manager"})
          for: 1m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
      - name: certificates
        params:
          extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests
        rules:
        - alert: CertManagerCertExpirySoon
          annotations:
            dashboard_url: https://grafana.example.com/d/TvuRo2iMk/cert-manager
            description: |
              The domain that this cert covers will be unavailable after {{"{{"}} $value | humanizeDuration {{"}}"}}.
              Clients using endpoints that this cert protects will start to fail in {{"{{"}} $value | humanizeDuration {{"}}"}}.
            runbook_url: https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagercertexpirysoon
            summary: |
              The cert {{"{{"}} $labels.name {{"}}"}} is {{"{{"}} $value | humanizeDuration {{"}}"}} from
              expiry, it should have renewed over a week ago.
          expr: |
            avg by (exported_namespace, namespace, name) (
              certmanager_certificate_expiration_timestamp_seconds - time()
            ) < (21 * 24 * 3600) # 21 days in seconds
          for: 1h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CertManagerCertNotReady
          annotations:
            dashboard_url: https://grafana.example.com/d/TvuRo2iMk/cert-manager
            description: This certificate has not been ready to serve traffic for at least
              10m. If the cert is being renewed or there is another valid cert, the ingress
              controller _may_ be able to serve that instead.
            runbook_url: https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagercertnotready
            summary: "The cert {{"{{"}} $labels.name {{"}}"}} is not ready to serve traffic."
          expr: |
            max by (name, exported_namespace, namespace, condition) (
              certmanager_certificate_ready_status{condition!="True"} == 1
            )
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: CertManagerHittingRateLimits
          annotations:
            dashboard_url: https://grafana.example.com/d/TvuRo2iMk/cert-manager
            description: Depending on the rate limit, cert-manager may be unable to generate
              certificates for up to a week.
            runbook_url: https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagerhittingratelimits
            summary: Cert manager hitting LetsEncrypt rate limits.
          expr: |
            sum by (host) (
              rate(certmanager_http_acme_client_request_count{status="429"}[5m])
            ) > 0
          for: 5m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

    etcd:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: etcd
        params:
          extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests
        rules:
        - alert: EtcdHighFsyncDurationsIncreasing
          expr: (rate(etcd_disk_wal_fsync_duration_seconds_count{job="kube-etcd"}[10m] offset 10m) / rate(etcd_disk_wal_fsync_duration_seconds_count{job="kube-etcd"}[10m] offset 10m)) > 1.15
          for: 2m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
          annotations:
            summary: "Etcd high deviv fsync durations (instance {{"{{"}} $labels.instance {{"}}"}})"
            description: "Etcd WAL fsync duration increasing is over 15%\n  VALUE = {{"{{"}} $value {{"}}"}}\n  LABELS = {{"{{"}} $labels {{"}}"}}"

        - alert: EtcdHighFsyncDurations
          expr: histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket[1m])) > 0.5
          for: 2m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
          annotations:
            summary: "Etcd high fsync durations (instance {{"{{"}} $labels.instance {{"}}"}})"
            description: "Etcd WAL fsync duration increasing, 99th percentile is over 0.5s\n  VALUE = {{"{{"}} $value {{"}}"}}\n  LABELS = {{"{{"}} $labels {{"}}"}}"

        - alert: EtcdHighCommitDurations
          expr: histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket[1m])) > 0.25
          for: 2m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
          annotations:
            summary: "Etcd high commit durations (instance {{"{{"}} $labels.instance {{"}}"}})"
            description: "Etcd commit duration increasing, 99th percentile is over 0.25s\n  VALUE = {{"{{"}} $value {{"}}"}}\n  LABELS = {{"{{"}} $labels {{"}}"}}"

        - alert: EtcdNoLeader
          expr: etcd_server_has_leader == 0
          for: 0m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
          annotations:
            summary: "Etcd no Leader (instance {{"{{"}} $labels.instance {{"}}"}})"
            description: "Etcd cluster have no leader\n  VALUE = {{"{{"}} $value {{"}}"}}\n  LABELS = {{"{{"}} $labels {{"}}"}}"

        - alert: EtcdHighNumberOfLeaderChanges
          expr: increase(etcd_server_leader_changes_seen_total[5m]) > 1
          for: 0m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
          annotations:
            summary: "Etcd high number of leader changes (instance {{"{{"}} $labels.instance {{"}}"}})"
            description: "Etcd leader changed more than 1 times during 5 minutes\n  VALUE = {{"{{"}} $value {{"}}"}}\n  LABELS = {{"{{"}} $labels {{"}}"}}"

        - alert: etcdMembersDown
          annotations:
            description: "etcd cluster {{"{{"}} $labels.job {{"}}"}} - members are down ({{"{{"}} $value {{"}}"}})."
            summary: etcd cluster members are down.
          expr: |
            max without (endpoint) (
              sum without (instance) (up{job=~".*etcd.*"} == bool 0)
            or
              count without (To) (
                sum without (instance) (rate(etcd_network_peer_sent_failures_total{job=~".*etcd.*"}[120s])) > 0.01
              )
            )
            > 0
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: etcdDatabaseQuotaLowSpace
          annotations:
            description: |
              etcd cluster {{"{{"}} $labels.job {{"}}"}} - database size exceeds the defined
              quota on etcd instance {{"{{"}} $labels.instance {{"}}"}}, please defrag or increase the
              quota as the writes to etcd will be disabled when it is full.
            summary: etcd cluster database is running full.
          expr: |
            (last_over_time(etcd_mvcc_db_total_size_in_bytes[5m]) / last_over_time(etcd_server_quota_backend_bytes[5m]))*100 > 95
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: etcdExcessiveDatabaseGrowth
          annotations:
            description: |
              etcd cluster {{"{{"}} $labels.job {{"}}"}} - Predicting running out of disk
              space in the next four hours, based on write observations within the past
              four hours on etcd instance {{"{{"}} $labels.instance {{"}}"}}, please check as it might
              be disruptive.
            summary: etcd cluster database growing very fast.
          expr: |
            predict_linear(etcd_mvcc_db_total_size_in_bytes[4h], 4*60*60) > etcd_server_quota_backend_bytes
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: etcdDatabaseHighFragmentationRatio
          annotations:
            description: |
              etcd cluster {{"{{"}} $labels.job {{"}}"}} - database size in use on instance
              {{"{{"}} $labels.instance {{"}}"}} is {{"{{"}} $value | humanizePercentage {{"}}"}} of the actual
              allocated disk space, please run defragmentation (e.g. etcdctl defrag) to
              retrieve the unused fragmented disk space.
            runbook_url: https://etcd.io/docs/v3.5/op-guide/maintenance/#defragmentation
            summary: etcd database size in use is less than 50% of the actual allocated
              storage.
          expr: |
            (last_over_time(etcd_mvcc_db_total_size_in_use_in_bytes[5m]) / last_over_time(etcd_mvcc_db_total_size_in_bytes[5m])) < 0.5 and etcd_mvcc_db_total_size_in_use_in_bytes > 104857600
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
    api-usage:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: pre-release-lifecycle
        params:
          extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests
        rules:
        - alert: APIRemovedInNextReleaseInUse
          annotations:
            description: |
              Deprecated API that will be removed in the next version is being
              used. Removing the workload that is using the {{"{{"}} $labels.group {{"}}"}}.{{"{{"}} $labels.version
              {{"}}"}}/{{"{{"}} $labels.resource {{"}}"}} API might be necessary for a successful upgrade
              to the next cluster version. Refer to 'oc get apirequestcounts {{"{{"}} $labels.resource
              {{"}}"}}.{{"{{"}} $labels.version {{"}}"}}.{{"{{"}} $labels.group {{"}}"}} -o yaml' to identify the workload.
            summary: Deprecated API that will be removed in the next version is being used.
          expr: |
            group(apiserver_requested_deprecated_apis{removed_release="1.25"}) by (group,version,resource) and (sum by(group,version,resource) (rate(apiserver_request_total{system_client!="kube-controller-manager",system_client!="cluster-policy-controller"}[4h]))) > 0
          for: 1h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: info

        - alert: APIRemovedInNextEUSReleaseInUse
          annotations:
            description: |
              Deprecated API that will be removed in the next EUS version is
              being used. Removing the workload that is using the {{"{{"}} $labels.group {{"}}"}}.{{"{{"}}
              $labels.version {{"}}"}}/{{"{{"}} $labels.resource {{"}}"}} API might be necessary for a successful
              upgrade to the next EUS cluster version. Refer to 'oc get apirequestcounts
              {{"{{"}} $labels.resource {{"}}"}}.{{"{{"}} $labels.version {{"}}"}}.{{"{{"}} $labels.group {{"}}"}} -o yaml'
              to identify the workload.
            summary: Deprecated API that will be removed in the next EUS version is being used.
          expr: |
            group(apiserver_requested_deprecated_apis{removed_release=~"1\\.2[5]"}) by (group,version,resource) and (sum by(group,version,resource) (rate(apiserver_request_total{system_client!="kube-controller-manager",system_client!="cluster-policy-controller"}[4h]))) > 0
          for: 1h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: info
    audit-errors:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: apiserver-audit
        rules:
        - alert: AuditLogError
          annotations:
            description: An API Server had an error writing to an audit log.
            summary: |-
              An API Server instance was unable to write audit logs. This could be
              triggered by the node running out of space, or a malicious actor
              tampering with the audit logs.
          expr: |
            sum by (job, instance)(rate(apiserver_audit_error_total{job=~"apiserver|vmagent-kube-apiserver-client"}[5m])) / sum by (job, instance) (rate(apiserver_audit_event_total{job=~"apiserver|vmagent-kube-apiserver-client"}[5m])) > 0
          for: 1m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
    cluster-monitoring-victoriametrics:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: jobs
        rules:
        - alert: VMAgentJobAbsent
          expr: absent(up{job="vmagent-vmagent"})
          for: 2m
          annotations:
            description: VMAgent is absesnt in {{"{{"}} $labels.cluster_full_name }}.
            summary: VMAgent is absesnt in {{"{{"}} $labels.cluster_full_name }}.
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical

        - alert: VMAlertJobAbsent
          expr: absent(up{job="vmalert-vmalert"})
          for: 2m
          annotations:
            description: VMAlert is absesnt in {{"{{"}} $labels.cluster_full_name }}.
            summary: VMAlert is absesnt in {{"{{"}} $labels.cluster_full_name }}.
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical

        - alert: VMAlertmanagerJobAbsent
          expr: absent(up{job="vmalertmanager-alertmanager"})
          for: 2m
          annotations:
            description: VMAlertmanager is absesnt in {{"{{"}} $labels.cluster_full_name }}.
            summary: VMAlertmanager is absesnt in {{"{{"}} $labels.cluster_full_name }}.
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical

    cluster-monitoring-victoriametrics-operator:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: pods
        rules:
        - alert: ControlPlanePodsRestart
          expr: rate(kube_pod_container_status_restarts_total{namespace=~"kube-system"}[10m]) * 600>=1
          for: 1m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
          annotations:
            description: A control-plane pod restarted
            summary: |-
              An control plane pod restarted.
              This may be caused by updates in the cluster, or it may be a lack of resources.

        - alert: PodsRestart
          expr: rate(kube_pod_container_status_restarts_total{namespace=~"beget.*|kube.*"}[10m]) * 600>=1
          for: 1m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning
          annotations:
            description: Pod restarted
            summary: |-
              Pod restarted.
              This may be caused by updates in the cluster, or it may be a lack of resources or incorrect configuration.
    cluster-monitoring-prometheus-operator:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: kubernetes.rules
        rules:
        - expr: sum(rate(container_cpu_usage_seconds_total{container="",pod!=""}[5m]))
            BY (pod, namespace)
          record: pod:container_cpu_usage:sum
        - expr: sum(container_fs_usage_bytes{pod!=""}) BY (pod, namespace)
          record: pod:container_fs_usage_bytes:sum
        - expr: sum(container_memory_usage_bytes{container!=""}) BY (namespace)
          record: namespace:container_memory_usage_bytes:sum
        - expr: sum(rate(container_cpu_usage_seconds_total{container!="POD",container!=""}[5m]))
            BY (namespace)
          record: namespace:container_cpu_usage:sum
        - expr: sum(container_memory_usage_bytes{container="",pod!=""}) BY (cluster) /
            sum(machine_memory_bytes) BY (cluster)
          record: cluster:memory_usage:ratio
        - expr: sum(container_spec_cpu_shares{container="",pod!=""}) / 1000 / sum(machine_cpu_cores)
          record: cluster:container_spec_cpu_shares:ratio
        - expr: sum(rate(container_cpu_usage_seconds_total{container="",pod!=""}[5m]))
            / sum(machine_cpu_cores)
          record: cluster:container_cpu_usage:ratio
        - expr: max without(endpoint, instance, job, pod, service) (kube_node_labels and
            on(node) kube_node_role{role="control-plane"})
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            label_node_role_kubernetes_io: master
            label_node_role_kubernetes_io_master: "true"
          record: cluster:master_nodes
        - expr: max without(endpoint, instance, job, pod, service) (kube_node_labels and
            on(node) kube_node_role{role="infra"})
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            label_node_role_kubernetes_io_infra: "true"
          record: cluster:infra_nodes
        - expr: max without(endpoint, instance, job, pod, service) (cluster:master_nodes
            and on(node) cluster:infra_nodes)
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            label_node_role_kubernetes_io_infra: "true"
            label_node_role_kubernetes_io_master: "true"
          record: cluster:master_infra_nodes
        - expr: cluster:master_infra_nodes or on (node) cluster:master_nodes or on (node)
            cluster:infra_nodes or on (node) max without(endpoint, instance, job, pod,
            service) (kube_node_labels)
          record: cluster:nodes_roles
        - expr: kube_node_labels and on(node) (sum(label_replace(node_cpu_info, "node",
            "$1", "instance", "(.*)")) by (node, package, core) == 2)
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            label_node_hyperthread_enabled: "true"
          record: cluster:hyperthread_enabled_nodes
        - expr: count(sum(virt_platform) by (instance, type, system_manufacturer, system_product_name,
            baseboard_manufacturer, baseboard_product_name)) by (type, system_manufacturer,
            system_product_name, baseboard_manufacturer, baseboard_product_name)
          record: cluster:virt_platform_nodes:sum
        - expr: |
            sum by(label_beta_kubernetes_io_instance_type, label_node_role_kubernetes_io, label_kubernetes_io_arch, label_node_openshift_io_os_id) (
              (
                cluster:master_nodes
                * on(node) group_left() max by(node)
                (
                  kube_node_status_capacity{resource="cpu",unit="core"}
                )
              )
              or on(node) (
                max without(endpoint, instance, job, pod, service)
                (
                  kube_node_labels
                ) * on(node) group_left() max by(node)
                (
                  kube_node_status_capacity{resource="cpu",unit="core"}
                )
              )
            )
          record: cluster:capacity_cpu_cores:sum
        - expr: |
            clamp_max(
              label_replace(
                sum by(instance, package, core) (
                  node_cpu_info{core!="",package!=""}
                  or
                  # Assume core = cpu and package = 0 for platforms that don't expose core/package labels.
                  label_replace(label_join(node_cpu_info{core="",package=""}, "core", "", "cpu"), "package", "0", "package", "")
                ) > 1,
                "label_node_hyperthread_enabled",
                "true",
                "instance",
                "(.*)"
              ) or on (instance, package)
              label_replace(
                sum by(instance, package, core) (
                  label_replace(node_cpu_info{core!="",package!=""}
                  or
                  # Assume core = cpu and package = 0 for platforms that don't expose core/package labels.
                  label_join(node_cpu_info{core="",package=""}, "core", "", "cpu"), "package", "0", "package", "")
                ) <= 1,
                "label_node_hyperthread_enabled",
                "false",
                "instance",
                "(.*)"
              ),
              1
            )
          record: cluster:cpu_core_hyperthreading
        - expr: |
            topk by(node) (1, cluster:nodes_roles) * on (node)
              group_right( label_beta_kubernetes_io_instance_type, label_node_role_kubernetes_io, label_node_openshift_io_os_id, label_kubernetes_io_arch,
                          label_node_role_kubernetes_io_master, label_node_role_kubernetes_io_infra)
            label_replace( cluster:cpu_core_hyperthreading, "node", "$1", "instance", "(.*)" )
          record: cluster:cpu_core_node_labels
        - expr: count(cluster:cpu_core_node_labels) by (label_beta_kubernetes_io_instance_type,
            label_node_hyperthread_enabled)
          record: cluster:capacity_cpu_cores_hyperthread_enabled:sum
        - expr: |
            sum by(label_beta_kubernetes_io_instance_type, label_node_role_kubernetes_io)
            (
              (
                cluster:master_nodes
                * on(node) group_left() max by(node)
                (
                  kube_node_status_capacity{resource="memory",unit="byte"}
                )
              )
              or on(node)
              (
                max without(endpoint, instance, job, pod, service)
                (
                  kube_node_labels
                )
                * on(node) group_left() max by(node)
                (
                  kube_node_status_capacity{resource="memory",unit="byte"}
                )
              )
            )
          record: cluster:capacity_memory_bytes:sum
        - expr: sum(1 - rate(node_cpu_seconds_total{mode="idle"}[2m]) * on(namespace,
            pod) group_left(node) node_namespace_pod:kube_pod_info:{pod=~"node-exporter.+"})
          record: cluster:cpu_usage_cores:sum
        - expr: sum(node_memory_MemTotal_bytes{job="node-exporter"} - node_memory_MemAvailable_bytes{job="node-exporter"})
          record: cluster:memory_usage_bytes:sum
        - expr: sum(rate(container_cpu_usage_seconds_total{namespace!~"openshift-.+",pod!="",container=""}[5m]))
          record: workload:cpu_usage_cores:sum
        - expr: cluster:cpu_usage_cores:sum - workload:cpu_usage_cores:sum
          record: openshift:cpu_usage_cores:sum
        - expr: sum(container_memory_working_set_bytes{namespace!~"openshift-.+",pod!="",container=""})
          record: workload:memory_usage_bytes:sum
        - expr: cluster:memory_usage_bytes:sum - workload:memory_usage_bytes:sum
          record: openshift:memory_usage_bytes:sum
        - expr: sum(cluster:master_nodes or on(node) kube_node_labels ) BY (label_beta_kubernetes_io_instance_type,
            label_node_role_kubernetes_io, label_kubernetes_io_arch, label_node_openshift_io_os_id)
          record: cluster:node_instance_type_count:sum
        - expr: |
            sum by(provisioner) (
              topk by (namespace, persistentvolumeclaim) (
                1, kube_persistentvolumeclaim_resource_requests_storage_bytes
              ) * on(namespace, persistentvolumeclaim) group_right()
              topk by(namespace, persistentvolumeclaim) (
                1, kube_persistentvolumeclaim_info * on(storageclass) group_left(provisioner) topk by(storageclass) (1, max by(storageclass, provisioner) (kube_storageclass_info))
              )
            )
          record: cluster:kube_persistentvolumeclaim_resource_requests_storage_bytes:provisioner:sum
        - expr: (sum(node_role_os_version_machine:cpu_capacity_cores:sum{label_node_role_kubernetes_io_master="",label_node_role_kubernetes_io_infra=""}
            or absent(__does_not_exist__)*0)) + ((sum(node_role_os_version_machine:cpu_capacity_cores:sum{label_node_role_kubernetes_io_master="true"}
            or absent(__does_not_exist__)*0) * ((max(cluster_master_schedulable == 1)*0+1)
            or (absent(cluster_master_schedulable == 1)*0))))
          record: workload:capacity_physical_cpu_cores:sum
        - expr: min_over_time(workload:capacity_physical_cpu_cores:sum[5m:15s])
          record: cluster:usage:workload:capacity_physical_cpu_cores:min:5m
        - expr: max_over_time(workload:capacity_physical_cpu_cores:sum[5m:15s])
          record: cluster:usage:workload:capacity_physical_cpu_cores:max:5m
        - expr: |
            sum  by (provisioner) (
              topk by (namespace, persistentvolumeclaim) (
                1, kubelet_volume_stats_used_bytes
              ) * on (namespace,persistentvolumeclaim) group_right()
              topk by (namespace, persistentvolumeclaim) (
                1, kube_persistentvolumeclaim_info * on(storageclass) group_left(provisioner) topk by(storageclass) (1, max by(storageclass, provisioner) (kube_storageclass_info))
              )
            )
          record: cluster:kubelet_volume_stats_used_bytes:provisioner:sum
        - expr: sum by (instance) (apiserver_storage_objects)
          record: instance:etcd_object_counts:sum
        - expr: topk(500, max by(resource) (apiserver_storage_objects))
          record: cluster:usage:resources:sum
        - expr: count(count (kube_pod_restart_policy{type!="Always",namespace!~"openshift-.+"})
            by (namespace,pod))
          record: cluster:usage:pods:terminal:workload:sum
        - expr: sum(max(kubelet_containers_per_pod_count_sum) by (instance))
          record: cluster:usage:containers:sum
        - expr: count(cluster:cpu_core_node_labels) by (label_kubernetes_io_arch, label_node_hyperthread_enabled,
            label_node_openshift_io_os_id,label_node_role_kubernetes_io_master,label_node_role_kubernetes_io_infra)
          record: node_role_os_version_machine:cpu_capacity_cores:sum
        - expr: count(max(cluster:cpu_core_node_labels) by (node, package, label_beta_kubernetes_io_instance_type,
            label_node_hyperthread_enabled, label_node_role_kubernetes_io) ) by ( label_beta_kubernetes_io_instance_type,
            label_node_hyperthread_enabled, label_node_role_kubernetes_io)
          record: cluster:capacity_cpu_sockets_hyperthread_enabled:sum
        - expr: count (max(cluster:cpu_core_node_labels) by (node, package, label_kubernetes_io_arch,
            label_node_hyperthread_enabled, label_node_openshift_io_os_id,label_node_role_kubernetes_io_master,label_node_role_kubernetes_io_infra)
            ) by (label_kubernetes_io_arch, label_node_hyperthread_enabled, label_node_openshift_io_os_id,label_node_role_kubernetes_io_master,label_node_role_kubernetes_io_infra)
          record: node_role_os_version_machine:cpu_capacity_sockets:sum
        - expr: max(alertmanager_integrations{namespace="in-cloud-monitoring"})
          record: cluster:alertmanager_integrations:max
        - expr: sum by(plugin_name, volume_mode)(pv_collector_total_pv_count)
          record: cluster:kube_persistentvolume_plugin_type_counts:sum
        - expr: sum by(version)(vsphere_vcenter_info)
          record: cluster:vsphere_vcenter_info:sum
        - expr: sum by(version)(vsphere_esxi_version_total)
          record: cluster:vsphere_esxi_version_total:sum
        - expr: sum by(hw_version)(vsphere_node_hw_version_total)
          record: cluster:vsphere_node_hw_version_total:sum
        - expr: |
            sum(
              min by (node) (kube_node_status_condition{condition="Ready",status="true"})
                and
              max by (node) (kube_node_role{role="control-plane"})
            ) == bool sum(kube_node_role{role="control-plane"})
          record: cluster:control_plane:all_nodes_ready

        - alert: ClusterMonitoringOperatorReconciliationErrors
          annotations:
            description: Errors are occurring during reconciliation cycles. Inspect the
              cluster-monitoring-operator log for potential root causes.
            summary: Cluster Monitoring Operator is experiencing unexpected reconciliation
              errors.
          expr: max_over_time(cluster_monitoring_operator_last_reconciliation_successful[5m])
            == 0
          for: 1h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: AlertmanagerReceiversNotConfigured
          annotations:
            description: Alerts are not configured to be sent to a notification system,
              meaning that you may not be notified in a timely fashion when important
              failures occur. Check the OpenShift documentation to learn how to configure
              notifications with Alertmanager.
            summary: Receivers (notification integrations) are not configured on Alertmanager
          expr: cluster:alertmanager_integrations:max == 0
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: MultipleContainersOOMKilled
          annotations:
            description: Multiple containers were out of memory killed within the past
              15 minutes. There are many potential causes of OOM errors, however issues
              on a specific node or containers breaching their limits is common.
            summary: Containers are being killed due to OOM
          expr: sum(max by(namespace, container, pod) (increase(kube_pod_container_status_restarts_total[12m]))
            and max by(namespace, container, pod) (kube_pod_container_status_last_terminated_reason{reason="OOMKilled"})
            == 1) > 5
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: info
        - expr: avg_over_time((((count((max by (node) (up{job="kubelet",metrics_path="/metrics"}
            == 1) and max by (node) (kube_node_status_condition{condition="Ready",status="true"}
            == 1) and min by (node) (kube_node_spec_unschedulable == 0))) / scalar(count(min
            by (node) (kube_node_spec_unschedulable == 0))))))[5m:1s])
          record: cluster:usage:kube_schedulable_node_ready_reachable:avg5m
        - expr: avg_over_time((count(max by (node) (kube_node_status_condition{condition="Ready",status="true"}
            == 1)) / scalar(count(max by (node) (kube_node_status_condition{condition="Ready",status="true"}))))[5m:1s])
          record: cluster:usage:kube_node_ready:avg5m
        - expr: (max without (condition,container,endpoint,instance,job,service) (((kube_pod_status_ready{condition="false"}
            == 1)*0 or (kube_pod_status_ready{condition="true"} == 1)) * on(pod,namespace)
            group_left() group by (pod,namespace) (kube_pod_status_phase{phase=~"Running|Unknown|Pending"}
            == 1)))
          record: kube_running_pod_ready
        - expr: avg(kube_running_pod_ready{namespace=~"openshift-.*"})
          record: cluster:usage:openshift:kube_running_pod_ready:avg
        - expr: avg(kube_running_pod_ready{namespace!~"openshift-.*"})
          record: cluster:usage:workload:kube_running_pod_ready:avg
      - interval: 30s
        name: kubernetes-recurring.rules
        rules:
        - expr: sum_over_time(workload:capacity_physical_cpu_cores:sum[30s:1s]) + ((cluster:usage:workload:capacity_physical_cpu_core_seconds
            offset 25s) or (absent(cluster:usage:workload:capacity_physical_cpu_core_seconds
            offset 25s)*0))
          record: cluster:usage:workload:capacity_physical_cpu_core_seconds
      - name: openshift-ingress.rules
        rules:
        - expr: sum by (code) (rate(haproxy_server_http_responses_total[5m]) > 0)
          record: code:cluster:ingress_http_request_count:rate5m:sum
        - expr: sum (rate(haproxy_frontend_bytes_in_total[5m]))
          record: cluster:usage:ingress_frontend_bytes_in:rate5m:sum
        - expr: sum (rate(haproxy_frontend_bytes_out_total[5m]))
          record: cluster:usage:ingress_frontend_bytes_out:rate5m:sum
        - expr: sum (haproxy_frontend_current_sessions)
          record: cluster:usage:ingress_frontend_connections:sum
        - expr: sum(max without(service,endpoint,container,pod,job,namespace) (increase(haproxy_server_http_responses_total{code!~"2xx|1xx|4xx|3xx",exported_namespace!~"openshift-.*"}[5m])
            > 0)) / sum (max without(service,endpoint,container,pod,job,namespace) (increase(haproxy_server_http_responses_total{exported_namespace!~"openshift-.*"}[5m])))
            or absent(__does_not_exist__)*0
          record: cluster:usage:workload:ingress_request_error:fraction5m
        - expr: sum (max without(service,endpoint,container,pod,job,namespace) (irate(haproxy_server_http_responses_total{exported_namespace!~"openshift-.*"}[5m])))
            or absent(__does_not_exist__)*0
          record: cluster:usage:workload:ingress_request_total:irate5m
        - expr: sum(max without(service,endpoint,container,pod,job,namespace) (increase(haproxy_server_http_responses_total{code!~"2xx|1xx|4xx|3xx",exported_namespace=~"openshift-.*"}[5m])
            > 0)) / sum (max without(service,endpoint,container,pod,job,namespace) (increase(haproxy_server_http_responses_total{exported_namespace=~"openshift-.*"}[5m])))
            or absent(__does_not_exist__)*0
          record: cluster:usage:openshift:ingress_request_error:fraction5m
        - expr: sum (max without(service,endpoint,container,pod,job,namespace) (irate(haproxy_server_http_responses_total{exported_namespace=~"openshift-.*"}[5m])))
            or absent(__does_not_exist__)*0
          record: cluster:usage:openshift:ingress_request_total:irate5m
        - expr: sum(ingress_controller_aws_nlb_active) or vector(0)
          record: cluster:ingress_controller_aws_nlb_active:sum
      - name: openshift-build.rules
        rules:
        - expr: sum by (strategy) (openshift_build_status_phase_total)
          record: openshift:build_by_strategy:sum
      - name: in-cloud-monitoring.rules
        rules:
        - expr: sum by (job,namespace) (max without(instance) (prometheus_tsdb_head_series{namespace=~"in-cloud-monitoring|openshift-user-workload-monitoring"}))
          record: openshift:prometheus_tsdb_head_series:sum
        - expr: sum by(job,namespace) (max without(instance) (rate(prometheus_tsdb_head_samples_appended_total{namespace=~"in-cloud-monitoring|openshift-user-workload-monitoring"}[2m])))
          record: openshift:prometheus_tsdb_head_samples_appended_total:sum
        - expr: sum by (namespace) (max without(instance) (container_memory_working_set_bytes{namespace=~"in-cloud-monitoring|openshift-user-workload-monitoring",
            container=""}))
          record: monitoring:container_memory_working_set_bytes:sum
        - expr: topk(3, sum by(namespace, job)(sum_over_time(scrape_series_added[1h])))
          record: namespace_job:scrape_series_added:topk3_sum1h
        - expr: topk(3, max by(namespace, job) (topk by(namespace,job) (1, scrape_samples_post_metric_relabeling)))
          record: namespace_job:scrape_samples_post_metric_relabeling:topk3
        - expr: sum by(exported_service) (rate(haproxy_server_http_responses_total{exported_namespace="in-cloud-monitoring",
            exported_service=~"alertmanager-main|prometheus-k8s|prometheus"}[5m]))
          record: monitoring:haproxy_server_http_responses_total:sum
        - expr: max by (cluster, namespace, workload, pod) (label_replace(label_replace(kube_pod_owner{job="kube-state-metrics",
            owner_kind="ReplicationController"},"replicationcontroller", "$1", "owner_name",
            "(.*)") * on(replicationcontroller, namespace) group_left(owner_name) topk
            by(replicationcontroller, namespace) (1, max by (replicationcontroller, namespace,
            owner_name) (kube_replicationcontroller_owner{job="kube-state-metrics"})),"workload",
            "$1", "owner_name", "(.*)"))
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            workload_type: deploymentconfig
          record: namespace_workload_pod:kube_pod_owner:relabel
      - name: openshift-etcd-telemetry.rules
        rules:
        - expr: sum by (instance) (etcd_mvcc_db_total_size_in_bytes{job="etcd"})
          record: instance:etcd_mvcc_db_total_size_in_bytes:sum
        - expr: histogram_quantile(0.99, sum by (instance, le) (rate(etcd_disk_wal_fsync_duration_seconds_bucket{job="etcd"}[5m])))
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            quantile: "0.99"
          record: instance:etcd_disk_wal_fsync_duration_seconds:histogram_quantile
        - expr: histogram_quantile(0.99, sum by (instance, le) (rate(etcd_network_peer_round_trip_time_seconds_bucket{job="etcd"}[5m])))
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            quantile: "0.99"
          record: instance:etcd_network_peer_round_trip_time_seconds:histogram_quantile
        - expr: sum by (instance) (etcd_mvcc_db_total_size_in_use_in_bytes{job="etcd"})
          record: instance:etcd_mvcc_db_total_size_in_use_in_bytes:sum
        - expr: histogram_quantile(0.99, sum by (instance, le) (rate(etcd_disk_backend_commit_duration_seconds_bucket{job="etcd"}[5m])))
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            quantile: "0.99"
          record: instance:etcd_disk_backend_commit_duration_seconds:histogram_quantile
      - name: openshift-sre.rules
        rules:
        - expr: sum(rate(apiserver_request_total{job="apiserver"}[10m])) BY (code)
          record: code:apiserver_request_total:rate:sum



    cpu-utilization:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: control-plane-cpu-utilization
        params:
          extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests
        rules:
        - alert: HighOverallControlPlaneCPU
          annotations:
            description: Given three control plane nodes, the overall CPU utilization
              may only be about 2/3 of all available capacity. This is because if a single
              control plane node fails, the remaining two must handle the load of the
              cluster in order to be HA. If the cluster is using more than 2/3 of all
              capacity, if one control plane node fails, the remaining two are likely
              to fail when they take the load. To fix this, increase the CPU and memory
              on your control plane nodes.
            runbook_url: https://github.com/openshift/runbooks/blob/master/alerts/cluster-kube-apiserver-operator/ExtremelyHighIndividualControlPlaneCPU.md
            summary: CPU utilization across all three control plane nodes is higher than
              two control plane nodes can sustain; a single control plane node outage
              may cause a cascading failure; increase available CPU.
          expr: |
            sum(
              100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
              AND on (instance) label_replace( kube_node_role{role="control-plane"}, "instance", "$1", "node", "(.+)" )
            )
            /
            count(kube_node_role{role="control-plane"})
            > 60
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: ExtremelyHighIndividualControlPlaneCPU
          annotations:
            description: Extreme CPU pressure can cause slow serialization and poor performance
              from the kube-apiserver and etcd. When this happens, there is a risk of
              clients seeing non-responsive API requests which are issued again causing
              even more CPU pressure. It can also cause failing liveness probes due to
              slow etcd responsiveness on the backend. If one kube-apiserver fails under
              this condition, chances are you will experience a cascade as the remaining
              kube-apiservers are also under-provisioned. To fix this, increase the CPU
              and memory on your control plane nodes.
            runbook_url: https://github.com/openshift/runbooks/blob/master/alerts/cluster-kube-apiserver-operator/ExtremelyHighIndividualControlPlaneCPU.md
            summary: CPU utilization on a single control plane node is very high, more
              CPU pressure is likely to cause a failover; increase available CPU.
          expr: |
            100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 90 AND on (instance) label_replace( kube_node_role{role="control-plane"}, "instance", "$1", "node", "(.+)" )
          for: 5m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: ExtremelyHighIndividualControlPlaneCPU
          annotations:
            description: Extreme CPU pressure can cause slow serialization and poor performance
              from the kube-apiserver and etcd. When this happens, there is a risk of
              clients seeing non-responsive API requests which are issued again causing
              even more CPU pressure. It can also cause failing liveness probes due to
              slow etcd responsiveness on the backend. If one kube-apiserver fails under
              this condition, chances are you will experience a cascade as the remaining
              kube-apiservers are also under-provisioned. To fix this, increase the CPU
              and memory on your control plane nodes.
            runbook_url: https://github.com/openshift/runbooks/blob/master/alerts/cluster-kube-apiserver-operator/ExtremelyHighIndividualControlPlaneCPU.md
            summary: Sustained high CPU utilization on a single control plane node, more
              CPU pressure is likely to cause a failover; increase available CPU.
          expr: |
            100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 90 AND on (instance) label_replace( kube_node_role{role="control-plane"}, "instance", "$1", "node", "(.+)" )
          for: 1h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical
    kube-apiserver-requests:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
        - name: apiserver-requests-in-flight
          params:
            extra_label: ["in-cloud_metrics=infra"]
          rules:
            - expr: |
                max_over_time(sum(apiserver_current_inflight_requests) by (request_kind, cluster_full_name)[2m:])
              record: cluster:apiserver_current_inflight_requests:sum:max_over_time:2m
    node-exporter-rules:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
        - name: node-exporter.rules
          params:
            extra_label: ["in-cloud_metrics=infra"]      # apply additional label filter "env=dev" for all requests

          rules:
            - expr: |
                count without (cpu, mode) (
                  node_cpu_seconds_total{job="node-exporter",mode="idle"}
                )
              record: instance:node_num_cpu:sum
            - expr: |
                1 - avg without (cpu) (
                  sum without (mode) (rate(node_cpu_seconds_total{job="node-exporter", mode=~"idle|iowait|steal"}[1m]))
                )
              record: instance:node_cpu_utilisation:rate1m
            - expr: |
                (
                  node_load1{job="node-exporter"}
                /
                  instance:node_num_cpu:sum{job="node-exporter"}
                )
              record: instance:node_load1_per_cpu:ratio
            - expr: |
                1 - (
                  (
                    node_memory_MemAvailable_bytes{job="node-exporter"}
                    or
                    (
                      node_memory_Buffers_bytes{job="node-exporter"}
                      +
                      node_memory_Cached_bytes{job="node-exporter"}
                      +
                      node_memory_MemFree_bytes{job="node-exporter"}
                      +
                      node_memory_Slab_bytes{job="node-exporter"}
                    )
                  )
                /
                  node_memory_MemTotal_bytes{job="node-exporter"}
                )
              record: instance:node_memory_utilisation:ratio
            - expr: |
                rate(node_vmstat_pgmajfault{job="node-exporter"}[1m])
              record: instance:node_vmstat_pgmajfault:rate1m
            - expr: |
                rate(node_disk_io_time_seconds_total{job="node-exporter", device=~"mmcblk.p.+|nvme.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+"}[1m])
              record: instance_device:node_disk_io_time_seconds:rate1m
            - expr: |
                rate(node_disk_io_time_weighted_seconds_total{job="node-exporter", device=~"mmcblk.p.+|nvme.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+"}[1m])
              record: instance_device:node_disk_io_time_weighted_seconds:rate1m
            - expr: |
                sum without (device) (
                  rate(node_network_receive_bytes_total{job="node-exporter", device!="lo"}[1m])
                )
              record: instance:node_network_receive_bytes_excluding_lo:rate1m
            - expr: |
                sum without (device) (
                  rate(node_network_transmit_bytes_total{job="node-exporter", device!="lo"}[1m])
                )
              record: instance:node_network_transmit_bytes_excluding_lo:rate1m
            - expr: |
                sum without (device) (
                  rate(node_network_receive_drop_total{job="node-exporter", device!="lo"}[1m])
                )
              record: instance:node_network_receive_drop_excluding_lo:rate1m
            - expr: |
                sum without (device) (
                  rate(node_network_transmit_drop_total{job="node-exporter", device!="lo"}[1m])
                )
              record: instance:node_network_transmit_drop_excluding_lo:rate1m
    podsecurity:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: pod-security-violation
        rules:
        - alert: PodSecurityViolation
          annotations:
            description: |
              A workload (pod, deployment, deamonset, ...) was created somewhere
              in the cluster but it did not match the PodSecurity "{{"{{"}} $labels.policy_level
              {{"}}"}}" profile defined by its namespace either via the cluster-wide configuration
              (which triggers on a "restricted" profile violations) or by the namespace
              local Pod Security labels. Refer to Kubernetes documentation on Pod Security
              Admission to learn more about these violations.
            summary: One or more workloads users created in the cluster don't match their
              Pod Security profile
          expr: |
            sum(increase(pod_security_evaluations_total{decision="deny",mode="audit",resource="pod"}[1d])) by (policy_level) > 0
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            namespace: in-cloud-monitoring
            severity: info
    prometheus-k8s-prometheus-rules:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: prometheus
        rules:
        - alert: PrometheusBadConfig
          annotations:
            description: "Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has failed to reload its configuration."
            summary: Failed Prometheus configuration reload.
          expr: |
            # Without max_over_time, failed scrapes could create false negatives, see
            # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
            max_over_time(prometheus_config_last_reload_successful{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) == 0
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusNotificationQueueRunningFull
          annotations:
            description: "Alert notification queue of Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} is running full."
            summary: Prometheus alert notification queue predicted to run full in less
              than 30m.
          expr: |
            # Without min_over_time, failed scrapes could create false negatives, see
            # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
            (
              predict_linear(prometheus_notifications_queue_length{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m], 60 * 30)
            >
              min_over_time(prometheus_notifications_queue_capacity{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m])
            )
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusErrorSendingAlertsToSomeAlertmanagers
          annotations:
            description: |
              '{{"{{"}} printf "%.1f" $value {{"}}"}}% errors while sending alerts from
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} to Alertmanager {{"{{"}}$labels.alertmanager}}.'
            summary: Prometheus has encountered more than 1% errors sending alerts to
              a specific Alertmanager.
          expr: |
            (
              rate(prometheus_notifications_errors_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m])
            /
              rate(prometheus_notifications_sent_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m])
            )
            * 100
            > 1
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusNotConnectedToAlertmanagers
          annotations:
            description: "Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} is not connected to any Alertmanagers."
            summary: Prometheus is not connected to any Alertmanagers.
          expr: |
            # Without max_over_time, failed scrapes could create false negatives, see
            # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
            max_over_time(prometheus_notifications_alertmanagers_discovered{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) < 1
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusTSDBReloadsFailing
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has detected
              {{"{{"}}$value | humanize}} reload failures over the last 3h.
            summary: Prometheus has issues reloading blocks from disk.
          expr: |
            increase(prometheus_tsdb_reloads_failures_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[3h]) > 0
          for: 4h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusTSDBCompactionsFailing
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has detected
              {{"{{"}}$value | humanize}} compaction failures over the last 3h.
            summary: Prometheus has issues compacting blocks.
          expr: |
            increase(prometheus_tsdb_compactions_failed_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[3h]) > 0
          for: 4h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusNotIngestingSamples
          annotations:
            description: "Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} is not ingesting samples."
            summary: Prometheus is not ingesting samples.
          expr: |
            (
              rate(prometheus_tsdb_head_samples_appended_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) <= 0
            and
              (
                sum without(scrape_job) (prometheus_target_metadata_cache_entries{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}) > 0
              or
                sum without(rule_group) (prometheus_rule_group_rules{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}) > 0
              )
            )
          for: 10m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusDuplicateTimestamps
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} is dropping
              {{"{{"}} printf "%.4g" $value  {{"}}"}} samples/s with different values but duplicated
              timestamp.
            summary: Prometheus is dropping samples with duplicate timestamps.
          expr: |
            rate(prometheus_target_scrapes_sample_duplicate_timestamp_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 1h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusOutOfOrderTimestamps
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} is dropping
              {{"{{"}} printf "%.4g" $value  {{"}}"}} samples/s with timestamps arriving out of order.
            summary: Prometheus drops samples with out-of-order timestamps.
          expr: |
            rate(prometheus_target_scrapes_sample_out_of_order_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 1h
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusRemoteStorageFailures
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} failed to send
              {{"{{"}} printf "%.1f" $value {{"}}"}}% of the samples to {{"{{"}} $labels.remote_name {{"}}"}}:{{"{{"}} $labels.url {{"}}"}}
            summary: Prometheus fails to send samples to remote storage.
          expr: |
            (
              (rate(prometheus_remote_storage_failed_samples_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) or rate(prometheus_remote_storage_samples_failed_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]))
            /
              (
                (rate(prometheus_remote_storage_failed_samples_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) or rate(prometheus_remote_storage_samples_failed_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]))
              +
                (rate(prometheus_remote_storage_succeeded_samples_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) or rate(prometheus_remote_storage_samples_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]))
              )
            )
            * 100
            > 1
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusRemoteWriteBehind
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} remote write
              is {{"{{"}} printf "%.1f" $value {{"}}"}}s behind for {{"{{"}} $labels.remote_name}}:{{"{{"}} $labels.url {{"}}"}}.
            summary: Prometheus remote write is behind.
          expr: |
            # Without max_over_time, failed scrapes could create false negatives, see
            # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
            (
              max_over_time(prometheus_remote_storage_highest_timestamp_in_seconds{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m])
            - ignoring(remote_name, url) group_right
              max_over_time(prometheus_remote_storage_queue_highest_sent_timestamp_seconds{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m])
            )
            > 120
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: info

        - alert: PrometheusRemoteWriteDesiredShards
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} remote write
              desired shards calculation wants to run {{"{{"}} $value {{"}}"}} shards for queue
              {{"{{"}}$labels.remote_name}}:{{"{{"}}$labels.url}}, which **may exceed** the configured max.
              Please review 'prometheus_remote_storage_shards_max' for the corresponding job.
            summary: Prometheus remote write desired shards calculation wants to run more
              than configured max shards.
          expr: |
            # Without max_over_time, failed scrapes could create false negatives, see
            # https://www.robustperception.io/alerting-on-gauges-in-prometheus-2-0 for details.
            (
              max_over_time(prometheus_remote_storage_shards_desired{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m])
            >
              max_over_time(prometheus_remote_storage_shards_max{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m])
            )
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: VMRuleFailures
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has failed to
              evaluate {{"{{"}} printf "%.0f" $value {{"}}"}} rules in the last 5m.
            summary: Prometheus is failing rule evaluations.
          expr: |
            increase(prometheus_rule_evaluation_failures_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusMissingRuleEvaluations
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has missed {{"{{"}}
              printf "%.0f" $value {{"}}"}} rule group evaluations in the last 5m.
            summary: Prometheus is missing rule evaluations due to slow rule group evaluation.
          expr: |
            increase(prometheus_rule_group_iterations_missed_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusTargetLimitHit
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has dropped
              {{"{{"}} printf "%.0f" $value {{"}}"}} targets because the number of targets exceeded
              the configured target_limit.
            summary: Prometheus has dropped targets because some scrape configs have exceeded
              the targets limit.
          expr: |
            increase(prometheus_target_scrape_pool_exceeded_target_limit_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusLabelLimitHit
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has dropped
              {{"{{"}} printf "%.0f" $value {{"}}"}} targets because some samples exceeded the configured
              label_limit, label_name_length_limit or label_value_length_limit.
            summary: Prometheus has dropped targets because some scrape configs have exceeded
              the labels limit.
          expr: |
            increase(prometheus_target_scrape_pool_exceeded_label_limits_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusScrapeBodySizeLimitHit
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has failed {{"{{"}}
              printf "%.0f" $value {{"}}"}} scrapes in the last 5m because some targets exceeded
              the configured body_size_limit.
            summary: Prometheus has dropped some targets that exceeded body size limit.
          expr: |
            increase(prometheus_target_scrapes_exceeded_body_size_limit_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusScrapeSampleLimitHit
          annotations:
            description: |
              Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}} has failed {{"{{"}}
              printf "%.0f" $value {{"}}"}} scrapes in the last 5m because some targets exceeded
              the configured sample_limit.
            summary: Prometheus has failed scrapes that have exceeded the configured sample
              limit.
          expr: |
            increase(prometheus_target_scrapes_exceeded_sample_limit_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[5m]) > 0
          for: 15m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: warning

        - alert: PrometheusTargetSyncFailure
          annotations:
            description: |
              {{"{{"}} printf "%.0f" $value {{"}}"}} targets in Prometheus {{"{{"}}$labels.namespace}}/{{"{{"}}$labels.pod}}
              have failed to sync because invalid configuration was supplied.
            runbook_url: https://github.com/openshift/runbooks/blob/master/alerts/cluster-monitoring-operator/PrometheusTargetSyncFailure.md
            summary: Prometheus has failed to sync targets.
          expr: |
            increase(prometheus_target_sync_failed_total{job=~"prometheus-k8s|prometheus|prometheus-user-workload"}[30m]) > 0
          for: 5m
          labels:
            cluster_full_name: "{{ $labels.cluster_full_name }}"
            remotewrite_cluster: "{{ $labels.remotewrite_cluster }}"
            severity: critical
    prometheus-k8s-rules:
      additionalLabels:
        in-cloud-metrics: "infra"
      groups:
      - name: multus-admission-controller-monitor-service.rules
        rules:
        - expr: |
            max  (network_attachment_definition_enabled_instance_up) by (networks)
          record: cluster:network_attachment_definition_enabled_instance_up:max
        - expr: |
            max  (network_attachment_definition_instances) by (networks)
          record: cluster:network_attachment_definition_instances:max


  ` -}}
{{- end -}}