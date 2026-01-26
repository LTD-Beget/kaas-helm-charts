{{- define "newaddons.etcdBackup" -}}
  {{- printf `
etcdBackup:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsEtcdBackup
  namespace: beget-etcd-backups
  version: v1alpha1
  dependsOn:
    - vmOperator
  values:
    secret:
      s3:
        region: us-east-1
        accessKeyID: {{ $argsEtcdbackupS3AccessKey }}
        secretAccessKey: {{ $argsEtcdbackupS3SecretAccessKey }}
        endpoint: {{ $argsEtcdbackupS3SecretEndpoint}}
        s3ForcePathStyle: "true"
    app:
      args:
        - --use-etcd-wrapper=false
        - --schedule=0 */4 * * *  
        - --delta-snapshot-period=1h
        - --storage-provider=S3
        - --store-container={{ $argsEtcdbackupAppArgsStorecontainer }}
        - --store-prefix=etcd-{{ $clusterName }}
        - --garbage-collection-period=30m
        - --max-backups=6
        - --garbage-collection-policy=LimitBased
        - --compression-policy=gzip
        - --compress-snapshots=true
        - --etcd-snapshot-timeout=8m
        - --etcd-defrag-timeout=8m
        - --etcd-connection-timeout=30s
        - --delta-snapshot-memory-limit=204857600
        - --endpoints=https://$(NODE_IP):2379
        - --server-port=18080
        - --cacert=/etc/etcd-pki/ca.crt
        - --cert=/etc/etcd-pki/healthcheck-client.crt
        - --key=/etc/etcd-pki/healthcheck-client.key
        - --max-parallel-chunk-uploads=1
        - --min-chunk-size=16777212
        - --defragmentation-schedule=10 0 */3 * *
      resources:
        limits:
          cpu: 1000m
          memory: 2048Mi
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
  ` }}
{{- end -}}
