{{- define "xclusterComponents.addonsetIii.incloudUi" -}}
  {{- printf `
incloudUi:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIncloudUi
  namespace: beget-incloud-ui
  version: v1alpha1
  pluginName: kustomize-helm-with-values
  targetRevision: feat/vmcluster
  dependsOn:
  - dex
  values:
    incloud-web-chart:
      incloud-web-resources:
        enabled: true
        addons:
          argocd:
            enabled: true
          trivy:
            enabled: {{ $infraTrivyOperatorReady }}
      oauth2-proxy:
        config:
          clientID: "kubernetes"
          clientSecret: "incloud-ui-super-secret"
          cookieSecret: {{ $argsIncloudUICookieSecret }}
        extraArgs:
          upstream: "http://incloud-ui-incloud-web-chart.beget-incloud-ui.svc:80"
          redirect-url: "https://localhost/oauth2/callback"
          oidc-issuer-url: {{ printf "https://%%s:5554" $systemDexVip }}
          insecure-oidc-skip-issuer-verification: true
          login-url: https://localhost/dex/auth
          proxy-prefix: "/oauth2"
          skip-oidc-discovery: true
          oidc-jwks-url: {{ printf "https://%%s:5554/keys" $systemDexVip }}
          redeem-url: {{ printf "https://%%s:5554/token" $systemDexVip }}
        tolerations:
          - key: "node-role.kubernetes.io/control-plane"
            operator: "Exists"
            effect: "NoSchedule"
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
      ingress:
        enabled: false
      web:
        env:
          LOGIN_URL: "/oauth2/userinfo"
          LOGIN_USERNAME_FIELD: "email"
      tolerations:
        - key: "node-role.kubernetes.io/control-plane"
          operator: "Exists"
          effect: "NoSchedule"
        - key: "node-role.kubernetes.io/master"
          operator: "Exists"
          effect: "NoSchedule"
    {{ if $istioBaseReady }}
    istio:
      virtualService:
        enabled: true
        gateways:
          - beget-istio-gw/default
        hosts:
          - "*"
        http:
          route:
            host: incloud-ui-oauth2-proxy
            port: 80
    {{ end }}
    monitoring:
    {{ if $infraVMOperatorReady }}
      enabled: true
    {{ end }}
      secureService:
        enabled: true
        issuer:
          name: selfsigned-cluster-issuer
    tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "node-role.kubernetes.io/master"
        operator: "Exists"
        effect: "NoSchedule"
  ` }}
{{- end -}}