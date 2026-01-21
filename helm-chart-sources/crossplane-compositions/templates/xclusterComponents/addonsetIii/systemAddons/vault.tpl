{{- define "xclusterComponents.addonsetIii.vault" -}}
  {{- printf `
vault:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsVault
  namespace: beget-vault
  version: v1alpha1
  dependsOn:
    - certManager
  values:
    vault:
      injector:
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
      server:
        ha:
          enabled: true
          replicas: {{ $controlPlaneReplicas }}
          config: |
            ui = true

            listener "tcp" {
              address     = "0.0.0.0:8200"
              tls_disable = "true"
            }

            storage "etcd" {
              address        = "https://HOST_IP:2379"
              etcd_api       = "v3"
              ha_enabled     = "true"
              path           = "vault/"
              tls_ca_file    = "/vault/userconfig/etcd-client-vault/ca.crt"
              tls_cert_file  = "/vault/userconfig/etcd-client-vault/tls.crt"
              tls_key_file   = "/vault/userconfig/etcd-client-vault/tls.key"
              request_timeout = "5s"
              lock_timeout    = "15s"
            }
            
            service_registration "kubernetes" {}
        dataStorage:
          enabled: false
        postStart:
            - /bin/sh
            - '-c'
            - |
              set -eu
              # Ждём, пока Vault начнёт слушать порт (до 60 сек)
              i=0
              while [ $i -lt 60 ]; do
                nc -z 127.0.0.1 8200 >/dev/null 2>&1 && break
                sleep 1
                i=$((i+1))
              done

              # Разбираем ключи по запятой (без bash-массивов)
              UNSEAL="${UNSEAL_KEYS:-}"
              # уберём возможные CR/LF
              UNSEAL=$(printf '%%s' "$UNSEAL" | tr -d '\r\n')

              OLDIFS="$IFS"
              IFS=','
              for k in $UNSEAL; do
                k=$(printf '%%s' "$k" | tr -d ' \t')
                [ -n "$k" ] || continue
                vault operator unseal "$k" || true
              done
              IFS="$OLDIFS"

              vault status || true
        extraSecretEnvironmentVars:
          - envName: UNSEAL_KEYS
            secretName: vault-keys
            secretKey: UNSEAL_KEYS
        nodeSelector:
          node-role.kubernetes.io/control-plane: ""
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app.kubernetes.io/name: vault
              topologyKey: "kubernetes.io/hostname"
        volumes:
          - name: etcd-client-vault
            secret:
              secretName: etcd-client-vault
        volumeMounts:
          - name: etcd-client-vault
            mountPath: /vault/userconfig/etcd-client-vault
            readOnly: true
        standalone:
          enabled: false
        service:
          standby:
            enabled: false
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
    tls:
      enabled: true
      server:
        enabled: false
        certificate:
          name: vault-tls-server
          secretName: vault-tls-server
          commonName: vault
          dnsNames:
            - vault.beget-vault.svc
            - vault.beget-vault.svc.cluster.local
          usages:
            - digital signature
            - key encipherment
            - server auth
        issuer:
          name: selfsigned
          kind: ClusterIssuer
      client:
        enabled: true
        certificate:
          name: etcd-client-vault
          secretName: etcd-client-vault
          commonName: vault-client
          usages:
            - digital signature
            - key encipherment
            - client auth
        issuer:
          name: etcd-ca
          kind: ClusterIssuer
  ` }}
{{- end -}}
