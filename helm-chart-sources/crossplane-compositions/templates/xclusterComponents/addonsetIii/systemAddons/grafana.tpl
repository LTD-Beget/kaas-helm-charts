{{- define "xclusterComponents.addonsetIii.grafana" -}}
  {{- printf `
grafana:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsGrafana
  namespace: beget-grafana
  version: v1alpha1
  dependsOn: 
  - grafanaOperator
  values:
    grafana:
      name: grafana
      labels:
        dashboards: "grafana"
        app.kubernetes.io/name: grafana
      spec:
        config:
          auth:
              disable_login_form: "true"
          security:
            admin_user: {{ $argsGrafanaConfigAdminUser }}
            admin_password: {{ $argsGrafanaConfigAdminPassword }}
          server:
            root_url: /grafana/
            serve_from_sub_path: "true"
            protocol: http
            http_port: "3000"
          auth.generic_oauth:
            enabled: "true"
            name: "Dex"
            allow_sign_up: "true"
            client_id: ${GRAFANA_OIDC_CLIENT_ID}
            client_secret: ${GRAFANA_OIDC_CLIENT_SECRET}
            scopes: "openid email profile groups"
            role_attribute_path: |
              contains(email, 'admin@beget.ru') && 'Admin' || 'Viewer'
            role_attribute_strict: 'true'
            tls_skip_verify_insecure: "true"
            auth_url: {{ printf "https://%%s/auth" $systemIstioGwVip }}
            token_url: {{ printf "https://%%s/token" $systemIstioGwVip }}
            api_url: {{ printf "https://%%s/userinfo" $systemIstioGwVip }}
        deployment:
          spec:
            template:
              spec:
                tolerations:
                  - key: "node-role.kubernetes.io/control-plane"
                    operator: "Exists"
                    effect: "NoSchedule"
                  - key: "node-role.kubernetes.io/master"
                    operator: "Exists"
                    effect: "NoSchedule"
                priorityClassName: system-cluster-critical
                containers:
                  - name: grafana
                    env:
                      - name: GRAFANA_OIDC_CLIENT_ID
                        value: "grafana"
                      - name: GRAFANA_OIDC_CLIENT_SECRET
                        value: {{ $argsGrafanaDeploymentEnvOidcSecret }}
                    resources:
                      requests:
                        cpu: "100m"
                        memory: "128Mi"
                      limits:
                        cpu: "1"
                        memory: "2Gi"
                    volumeMounts:
                      - mountPath: /etc/ssl/certs
                        name: trusted-ca-certs
                        readOnly: true
                  - name: rbac-proxy
                    image: gcr.io/kubebuilder/kube-rbac-proxy:v0.14.4
                    args:
                      - --secure-listen-address=0.0.0.0:11043
                      - --upstream=http://127.0.0.1:3000
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
                volumes:
                  - name: trusted-ca-certs
                    configMap:
                      name: ca
                  - name: rbac-proxy-tls
                    secret:
                      defaultMode: 420
                      secretName: grafana-monitoring-svc-tls
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
    {{ if $istioBaseReady }}
    istio:
      virtualService:
        enabled: true
        gateways:
          - beget-istio-gw/default
        hosts:
          - "*"
        http:
          name: grafana
          route:
            host: grafana-service
            port: 3000
    {{ end }}
  ` }}
{{- end -}}
