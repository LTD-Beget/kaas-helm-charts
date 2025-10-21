{{- define "xclusterComponents.addonsetIii.dex" -}}
  {{- printf `
dex:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsDex
  namespace: beget-dex
  version: v1alpha1
  dependsOn:
  - certManager
  values:
    dex:
      config:
        issuer: https://dex.beget-dex.svc:5554
        storage:
          type: kubernetes
          config: { inCluster: true }
        web:
          https: 0.0.0.0:5554
          tlsCert: /etc/dex/tls/tls.crt
          tlsKey:  /etc/dex/tls/tls.key
        enablePasswordDB: true
        staticPasswords:
          - email: admin@beget.ru
            username: admin
            userID: 00000000-0000-0000-0000-000000000001
            hash: {{ $argsDexStaticPasswordsAdmin }}
          - email: artem@beget.ru
            username: artem
            userID: 00000000-0000-0000-0000-000000000001
            hash: "$2a$10$3MqvSHzzSj38YYNFDrkolONgKe9ejuphtk1Qe5gWNdm9ILVQYUOma"
        staticClients:
          - id: grafana
            name: Grafana
            secret: super-secret-grafana
            redirectURIs:
              - /grafana/login/generic_oauth
          - id: kubernetes
            name: incloud-ui-oauth2-proxy
            secret: incloud-ui-super-secret
            redirectURIs:
              - https://localhost/oauth2/callback
          - id: argocd
            name: Argocd
            secret: argo-cd-super-secret
            redirectURIs:
              - https://localhost/argocd/auth/callback
          - id: apiserver
            name: apiserver
            redirectURIs:
              - http://localhost:8000
              - http://127.0.0.1:8000
            secret: {{ $argsDexStaticClientsApiserver }}
      https:
        enabled: true
      volumeMounts:
        - name: tls
          mountPath: /etc/dex/tls
          readOnly: true
      volumes:
        - name: tls
          secret:
            secretName: {{ $clusterName }}-dex-tls
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    tls:
      enabled: true
      issuer:
        name: oidc-ca
        secretName: {{ $clusterName }}-ca-oidc
      certificate:
        name: {{ $clusterName }}-dex-tls
        secretName: {{ $clusterName }}-dex-tls
        commonName: dex
        dnsNames:
          - dex.beget-dex.svc
          - dex.beget-dex.svc.cluster.local
    rbac:
      enabled: true
      clusterRoleBinding:
        subjects:
          kind: User
          name: "admin@beget.ru"
    {{ if $infraVMOperatorReady }}
    monitoring:
      enabled: true
    {{ end }}
    {{ if $istioBaseReady }}
    istio:
      virtualService:
        enabled: true
        gateways:
          - beget-istio-gw/default
        hosts:
          - "*"
        http:
          name: dex
          route:
            host: dex
            port: 5554
      destinationRule:
        enabled: true
        host: dex
        trafficPolicy:
          tls:
            mode: SIMPLE
            insecureSkipVerify: true
    {{ end }}
  ` }}
{{- end -}}