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
            tls_skip_verify_insecure: "true"
            auth_url:  "https://localhost/auth"
            token_url: {{ printf "https://%%s:5554/token" $systemDexVip }}
            api_url: {{ printf "https://%%s:5554/userinfo" $systemDexVip }}
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
          name: grafana
          route:
            host: grafana-service
            port: 3000
    {{ end }}
  ` }}
{{- end -}}