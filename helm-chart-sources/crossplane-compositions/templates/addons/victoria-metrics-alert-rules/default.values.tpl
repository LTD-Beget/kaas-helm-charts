{{- define "addons.victoriametricsalertrules.default.values" -}}
  {{- printf `%s` `
victoria-metrics-k8s-stack:
  global:
    clusterLabel: cluster_full_name
  defaultRules:
    create: true
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
            severity: warning
      etcdHighNumberOfFailedGRPCRequests:
        spec:
          labels:
            severity: warning
      KubeContainerWaiting:
        spec:
          labels:
            severity: critical
      KubePodNotReady:
        spec:
          labels:
            severity: critical
      KubeCPUQuotaOvercommit:
        spec:
          labels:
            severity: critical
      CPUThrottlingHigh:
        spec:
          expr: |-
            sum(increase(container_cpu_cfs_throttled_periods_total{container!="", job="kubelet", metrics_path="/metrics/cadvisor", namespace=~"beget.*|kube.*"}[5m])) without (id, metrics_path, name, image, endpoint, job, node)
              /
            sum(increase(container_cpu_cfs_periods_total{job="kubelet", metrics_path="/metrics/cadvisor", namespace=~"beget.*|kube.*"}[5m])) without (id, metrics_path, name, image, endpoint, job, node)
              > ( 25 / 100 )
          labels:
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

alertRules:
  vmrules:
    auditErrors:
      enabled: true
      groups:
        apiserverAudit:
          enabled: true
          rules:
            AuditLogError:
              enabled: true
    coredns:
      enabled: true
      groups:
        coredns:
          enabled: true
          rules:
            CoreDNSDown:
              enabled: true
            CoreDNSLatencyHigh:
              enabled: true
            CoreDNSErrorsTooHigh:
              enabled: true
            CoreDNSErrorsHigh:
              enabled: true
        coredns_forward:
          enabled: true
          rules:
            CoreDNSForwardLatencyHigh:
              enabled: true
            CoreDNSForwardErrorsTooHigh:
              enabled: true
            CoreDNSForwardErrorsHigh:
              enabled: true
            CoreDNSForwardHealthcheckFailureCount:
              enabled: true
            CoreDNSForwardHealthcheckBrokenCount:
              enabled: true
    certManager:
      enabled: true
      groups:
        certManager:
          enabled: true
          rules:
            CertManagerAbsent:
              enabled: true
        certificates:
          enabled: true
          rules:
            CertManagerCertExpirySoon:
              enabled: true
            CertManagerCertNotReady:
              enabled: true
            CertManagerHittingRateLimits:
              enabled: true
    etcd:
      enabled: true
      groups:
        etcd:
          enabled: true
          rules:
            EtcdHighFsyncDurationsIncreasing:
              enabled: true
            EtcdHighFsyncDurations:
              enabled: true
            EtcdHighCommitDurations:
              enabled: true
            EtcdNoLeader:
              enabled: true
            EtcdHighNumberOfLeaderChanges:
              enabled: true
            etcdMembersDown:
              enabled: true
            etcdDatabaseQuotaLowSpace:
              enabled: true
            etcdExcessiveDatabaseGrowth:
              enabled: true
            etcdDatabaseHighFragmentationRatio:
              enabled: true
    clusterMonitoringVictoriaMetrics:
      enabled: true
      groups:
        jobs:
          enabled: true
          rules:
            VMAlertJobAbsent:
              enabled: true
            VMAlertmanagerJobAbsent:
              enabled: true
    clusterMonitoringVictoriaMetricsOperator:
      enabled: true
      groups:
        pods:
          enabled: true
          rules:
            ControlPlanePodsRestart:
              enabled: true
            PodsRestart:
              enabled: true
    cpuUtilization:
      enabled: true
      groups:
        controlPlaneCpuUtilization:
          enabled: true
          rules:
            HighOverallControlPlaneCPU:
              enabled: true
            HighIndividualControlPlaneCPU:
              enabled: true
            ExtremelyHighIndividualControlPlaneCPU:
              enabled: true
    kubeApiServerRequests:
      enabled: true
      groups:
        kubeApiServerRequestsInFlight:
          enabled: true
          rules:
            kubeApiServerRequestsInFlight:
              enabled: true
    podSecurity:
      enabled: true
      groups:
        PodSecurityViolation:
          enabled: true
          rules:
            PodSecurityViolation:
              enabled: true
    prometheusK8sPrometheusRules:
      enabled: true
      groups:
        prometheus:
          enabled: true
          rules:
            PrometheusBadConfig:
              enabled: true
            PrometheusNotificationQueueRunningFull:
              enabled: true
            PrometheusErrorSendingAlertsToSomeAlertmanagers:
              enabled: true
            PrometheusNotConnectedToAlertmanagers:
              enabled: true
            PrometheusTSDBReloadsFailing:
              enabled: true
            PrometheusTSDBCompactionsFailing:
              enabled: true
            PrometheusNotIngestingSamples:
              enabled: true
            PrometheusDuplicateTimestamps:
              enabled: true
            PrometheusOutOfOrderTimestamps:
              enabled: true
            PrometheusRemoteStorageFailures:
              enabled: true
            PrometheusRemoteWriteBehind:
              enabled: true
            PrometheusRemoteWriteDesiredShards:
              enabled: true
            VMRuleFailures:
              enabled: true
            PrometheusMissingRuleEvaluations:
              enabled: true
            PrometheusTargetLimitHit:
              enabled: true
            PrometheusLabelLimitHit:
              enabled: true
            PrometheusScrapeBodySizeLimitHit:
              enabled: true
            PrometheusScrapeSampleLimitHit:
              enabled: true
            PrometheusTargetSyncFailure:
              enabled: true
  ` -}}
{{- end -}}