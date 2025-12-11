{{- define "xclusterComponents.addonsetIii.incloudUi" -}}
  {{- printf `
incloudUi:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsIncloudUi
  namespace: beget-incloud-ui
  version: v1alpha1
  dependsOn:
  - certManager
  {{- if $systemEnabled }}
  - dex
  {{- end }}
  values:
    incloud-web-resources:
      enabled: true
      addons:
        argocd:
          enabled: true
        trivy:
          enabled: {{ $infraTrivyOperatorReady }}
    incloud-web-chart:
      oauth2-proxy:
        enabled: true
        config:
          clientID: "kubernetes"
          clientSecret: "incloud-ui-super-secret"
          cookieSecret: {{ $argsIncloudUICookieSecret }}
        extraArgs:
          upstream: "http://incloud-ui-incloud-web-chart.beget-incloud-ui.svc:8081"
          redirect-url: {{ printf "https://%%s/oauth2/callback" $systemIstioGwVip }}
          oidc-issuer-url: {{ printf "https://%%s/dex" $systemIstioGwVip }}
          insecure-oidc-skip-issuer-verification: true
          login-url: {{ printf "https://%%s/dex/auth" $systemIstioGwVip }}
          proxy-prefix: "/oauth2"
          skip-oidc-discovery: true
          oidc-jwks-url: {{ printf "https://%%s/keys" $systemIstioGwVip }}
          redeem-url: {{ printf "https://%%s/token" $systemIstioGwVip }}
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
          BASEPREFIX: "/openapi-ui"
          TITLE_TEXT: "Beget"
          LOGO_TEXT: " "
          FOOTER_TEXT: "Beget"
          CUSTOM_LOGO_SVG: "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4NyA0MCIgd2lkdGg9IjgwIiBoZWlnaHQ9IjM1IiBmaWxsPSJub25lIiBjbGFzcz0iYmVnZXQtaWNvbl9fY29udGVudCI+CiAgICA8cGF0aCBkPSJNNTEuMTE2OSAyMy43MDE4QzU1LjM3MjYgMjYuNzEzNSA1Ni4wNjg5IDMyLjEwNzMgNTMuNjc4NyAzNS45MTAzQzUxLjMwMzEgMzkuNjkwMyA0Ni41Mzg5IDQxLjA2MTggNDIuNTcxNCAzOS4xMzY0QzM4Ljg1ODIgMzcuMzM0NiAzNi4yNTkxIDMyLjUzMjYgMzguNDUxOCAyNy4zMjAyQzM4LjA5NTUgMjcuMjY1OCAzNy43NTU0IDI3LjIxMyAzNy40MTU0IDI3LjE2MDNDMzcuNDA0IDI3LjExNzQgMzcuMzkyNyAyNy4wNzI5IDM3LjM4MTMgMjcuMDNDMzguNzAxMSAyNi41ODUgNDAuMDIwOSAyNi4xMzk5IDQxLjQwODcgMjUuNjcwMUM0MS42MDYzIDI3LjE0MDUgNDEuNzk1OCAyOC41NDUgNDEuOTgzNiAyOS45NDc4QzQxLjk0OCAyOS45NjYgNDEuOTEwNyAyOS45ODU3IDQxLjg3NTEgMzAuMDAzOUM0MS41OTAxIDI5LjU4MDIgNDEuMzAzNSAyOS4xNTgyIDQxLjAwODcgMjguNzIxNEMzOS45NDE2IDMwLjYxMzggNDAuNDA0NyAzMy40ODcxIDQyLjAzNTQgMzUuMjUwOUM0My44NzUgMzcuMjM5IDQ2Ljc4OTkgMzcuNzIyIDQ5LjE0MjkgMzYuNDI2M0M1MS40OTU4IDM1LjEzMDYgNTIuNzA1NSAzMi4zNTc5IDUyLjA2MjYgMjkuNzI4NkM1MS40MDM1IDI3LjAzMzMgNDkuMTA0IDI1LjE3MDYgNDYuMzk4IDI1LjEzOTNDNDEuODQ0MyAyNS4wODY1IDM4LjI0NDUgMjEuODE3NiAzNy42Nzc3IDE3LjIyMzNDMzcuMTU0NiAxMi45Nzg1IDM5Ljk0IDguODUyNDMgNDQuMTAzNCA3LjcxMDA0QzQ4LjA1NjMgNi42MjM3IDUyLjIyOTQgOC41MjI3MyA1NC4wOTY1IDEyLjI1ODJDNTUuOTYwNCAxNS45ODUzIDU1LjAwNjYgMjAuNTM1MSA1MS44MTMyIDIzLjE1MjlDNTEuNTk0NiAyMy4zMjkyIDUxLjM3MTEgMjMuNTAwNyA1MS4xMTY5IDIzLjcwMThaTTQwLjQ1MDEgMTYuMjM1OUM0MC40Mzg3IDE5LjU2MjUgNDMuMDQyNyAyMi4yNTYxIDQ2LjI4OTUgMjIuMjc3NUM0OS41NjIzIDIyLjI5OSA1Mi4yMzkxIDE5LjYwMzcgNTIuMjQ0IDE2LjI4MjFDNTIuMjQ3MiAxMi45ODE4IDQ5LjYwMjggMTAuMjc2NyA0Ni4zNjQgMTAuMjY4NUM0My4xMDU4IDEwLjI1ODYgNDAuNDYxNCAxMi45MjkxIDQwLjQ1MDEgMTYuMjM1OVoiIGZpbGw9ImN1cnJlbnRDb2xvciI+PC9wYXRoPgogICAgPHBhdGggZD0iTTMuOTk1MjQgMTIuMzQzN0M0LjMzODU1IDEwLjkzMSA0LjYzOTc1IDkuNjE3MTQgNC45OTExNiA4LjMxODE1QzUuMDM5NzQgOC4xMzY4MiA1LjMxMzQxIDcuOTY4NjggNS41MTkwNyA3Ljg4OTU1QzguNjEzNjkgNi43MTA5IDEyLjA2OTQgNy43MTY0NiAxNC4yNjM3IDEwLjQxOTlDMTcuODQ3NCAxNC44MzEyIDE2LjUwOTggMjEuODAyNiAxMS41OTk4IDI0LjMwNUM3LjQ2MjMyIDI2LjQxMzMgMi40ODc2MSAyNC4zOTQgMC43MTExNTcgMTkuODA2M0MwLjMxNDQxIDE4Ljc4MjYgMC4wNTUzMTA5IDE3LjYzMiAwLjA0MDczNjUgMTYuNTM1OEMtMC4wMjcyNzcxIDExLjE0MzYgMC4wMDgzNDkwNiA1Ljc0ODIgMC4wMDgzNDkwNiAwLjM1NDQyQzAuMDA4MzQ5MDYgMC4yNDM5NzMgMC4wMTk2ODQ3IDAuMTM1MTc0IDAuMDI2MTYyMiAwQzAuOTU0MDYyIDAuMDAxNjQ4NDYgMS44NDQ3MiAwLjAwMTY0ODQ2IDIuODE3OTYgMC4wMDE2NDg0NkMyLjgxNzk2IDAuMjIwODk0IDIuODE3OTYgMC40NDAxNCAyLjgxNzk2IDAuNjYxMDM0QzIuODE3OTYgNS44NDU0NiAyLjgxNzk2IDExLjAyOTkgMi44MTc5NiAxNi4yMTI3QzIuODE3OTYgMTcuODE2NiAzLjI4NzU4IDE5LjI1NDEgNC4zNDAxNyAyMC40NjA3QzYuNDc3NzQgMjIuOTEyIDkuOTA0MzMgMjIuODgyMyAxMi4wMTYgMjAuNDA4QzE0LjExOTYgMTcuOTQ1MiAxMy45NDc5IDEzLjk5NTUgMTEuNjQxOSAxMS43MzU0QzkuNjQxOTkgOS43NzcwNSA2LjY2MjM1IDkuNzc4NjkgNC42NTkxOSAxMS43MzcxQzQuNDcyOTYgMTEuOTE4NCA0LjI3NTM5IDEyLjA4ODIgMy45OTUyNCAxMi4zNDM3WiIgZmlsbD0iY3VycmVudENvbG9yIj48L3BhdGg+CiAgICA8cGF0aCBkPSJNMzUuMjQwNiAxNy42OTc3QzMzLjA2NDEgMTcuNjk3NyAzMC44NzggMTcuNjk3NyAyOC42OTAyIDE3LjY5NzdDMjYuNTAyNSAxNy42OTc3IDI0LjMxNjMgMTcuNjk3NyAyMi4wNTczIDE3LjY5NzdDMjIuNTkzMyAxOS43NjY1IDIzLjY5MjggMjEuMjYxNyAyNS42NDI2IDIxLjk5MDNDMjcuNjU4NyAyMi43NDM2IDI5LjQwOTIgMjIuMTQwMyAzMS40NjEgMjAuMDM2OUMzMi4yMzUgMjAuNDk4NCAzMy4wMTg4IDIwLjk2NSAzMy44NDc5IDIxLjQ1OTVDMzIuNTAwNiAyMy4zODk4IDMwLjc4MDggMjQuNjU0MiAyOC41MjAyIDI1LjAxMTlDMjQuMDI5NyAyNS43MjI0IDE5Ljg2NzkgMjIuNDY2NyAxOS4yMjE4IDE3Ljc5MTdDMTguODA1NiAxNC43Nzk5IDE5LjUyMTMgMTIuMTAyOCAyMS42MDA2IDkuODkzODZDMjUuNjQ1OCA1LjU5MzAyIDMyLjQ1ODUgNy4wNzk5NCAzNC43MTI3IDEyLjcyOTJDMzUuMzU4OCAxNC4zNDMxIDM1LjU1OTYgMTYuMTgxMSAzNS4yNDA2IDE3LjY5NzdaTTMyLjM2NjIgMTQuODE3OEMzMi4wNTg1IDEyLjI5NTcgMjkuNjIxNCAxMC4yMTM3IDI3LjEwOTcgMTAuMjY0OEMyNC43MzA5IDEwLjMxNDIgMjIuMzExNSAxMi41MTgyIDIyLjEzMzQgMTQuODE3OEMyNS41MzU3IDE0LjgxNzggMjguOTM2NCAxNC44MTc4IDMyLjM2NjIgMTQuODE3OFoiIGZpbGw9ImN1cnJlbnRDb2xvciI+PC9wYXRoPgogICAgPHBhdGggZD0iTTczLjQ1NjQgMTcuNjkzQzY5LjA2MyAxNy42OTMgNjQuNzAzNyAxNy42OTMgNjAuMjU2OSAxNy42OTNDNjAuNzM3OCAxOS42NDY0IDYxLjczODYgMjEuMTIzNSA2My41Mzk0IDIxLjg2MzZDNjUuOTkxMSAyMi44NzI1IDY3Ljk4NjEgMjIuMDIzNSA2OS42MzYzIDIwLjAzMjJDNzAuNDIxNyAyMC40OTg3IDcxLjE5NTcgMjAuOTU3IDcyLjAzNzggMjEuNDU4MUM3MS44Njc4IDIxLjY5MDUgNzEuNzI1MyAyMS45MDMyIDcxLjU2NjYgMjIuMTAxQzY4LjMwODQgMjYuMTQ0NyA2Mi41NzI2IDI2LjE0NDcgNTkuMzA5NiAyMi4xMDQzQzU2LjQ3MjQgMTguNTg5OCA1Ni42NTIyIDEzLjI1NTMgNTkuNzE5MyA5Ljk1NTEyQzYzLjg3MTMgNS40ODc3OCA3MC45MjIxIDcuMTM2MjUgNzMuMDMwNSAxMy4wNjc0QzczLjU1MTkgMTQuNTMyOSA3My42OTYxIDE2LjAzMTQgNzMuNDU2NCAxNy42OTNaTTcwLjU1MTIgMTQuODE0OEM3MC4zMzEgMTIuMzQ1NCA2Ny43Nzg5IDEwLjE4MSA2NS4yMTg2IDEwLjI3QzYyLjg2ODkgMTAuMzUyNCA2MC4zNzE5IDEyLjY3ODQgNjAuMzQ1OSAxNC44MTQ4QzYzLjc0ODIgMTQuODE0OCA2Ny4xNDg5IDE0LjgxNDggNzAuNTUxMiAxNC44MTQ4WiIgZmlsbD0iY3VycmVudENvbG9yIj48L3BhdGg+CiAgICA8cGF0aCBkPSJNODUuNDA3NSAyMC42Njk5Qzg1LjcwODcgMjEuNTkxNCA4Ni4wMjQ0IDIyLjUyNjEgODYuMzA3OCAyMy40NzA3Qzg2LjM0NTEgMjMuNTk2IDg2LjI1NiAyMy44MzMzIDg2LjE0NzUgMjMuOTIwN0M4My43MDM5IDI1Ljg5NzIgNzkuMzQxMyAyNS40MDc2IDc3LjM2NTcgMjIuOTQ0OEM3Ni43NTUyIDIyLjE4MzIgNzYuMzk4OSAyMS4zMTI4IDc2LjM5NzMgMjAuMzIyMUM3Ni4zOTI0IDE0LjgxMjkgNzYuMzk0IDkuMzAzNzggNzYuMzk1NyAzLjc5NDYxQzc2LjM5NTcgMy42ODQxNiA3Ni40MDg2IDMuNTcyMDYgNzYuNDE4MyAzLjQzMzU5Qzc3LjMzNDkgMy40MzM1OSA3OC4yMjU2IDMuNDMzNTkgNzkuMTg0MiAzLjQzMzU5Qzc5LjE4NDIgNC45MjM4MSA3OS4xODQyIDYuNDE4OTYgNzkuMTg0MiA3Ljk1ODYzQzgwLjg5MSA3Ljk1ODYzIDgyLjUzMTUgNy45NTg2MyA4NC4yMTU2IDcuOTU4NjNDODQuMjE1NiA4LjkyNjI4IDg0LjIxNTYgOS44NDYxMiA4NC4yMTU2IDEwLjgxNzFDODIuNTY3MSAxMC44MTcxIDgwLjkyNjcgMTAuODE3MSA3OS4yMzQ0IDEwLjgxNzFDNzkuMjIxNSAxMS4wNDQ2IDc5LjIwMzcgMTEuMjI3NSA3OS4yMDM3IDExLjQwODlDNzkuMjAyIDE0LjI4NzEgNzkuMjEzNCAxNy4xNjUzIDc5LjE5MzkgMjAuMDQzNUM3OS4xODkxIDIwLjcyNDMgNzkuNDY3NiAyMS4yMTIzIDc5Ljk3OTMgMjEuNTkzMUM4MS4xOTcxIDIyLjUwMyA4My4zODE2IDIyLjUwOCA4NC41ODY0IDIxLjU3NDlDODQuODkyNSAyMS4zNDI1IDg1LjExNDQgMjAuOTk5NiA4NS40MDc1IDIwLjY2OTlaIiBmaWxsPSJjdXJyZW50Q29sb3IiPjwvcGF0aD4KPC9zdmc+CjxkaXYgc3R5bGU9Im1hcmdpbjogMCAtNnB4IiAvPgo="
          CUSTOM_TENANT_TEXT: " "
          ICON_SVG: "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0MCA0MCIgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSJub25lIiBjbGFzcz0iYmVnZXQtaWNvbl9fY29udGVudCI+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIDxwYXRoIGQ9Ik0yNi41MzggMjBDMjkuNTcwNyAxOC4wNzgxIDMxLjU4MzcgMTQuNjkzOCAzMS41ODM3IDEwLjgzOTdDMzEuNTgzNyA0Ljg1MzAzIDI2LjcyNzQgMCAyMC43MzY3IDBDMTQuNzQ2IDAgOS44ODk2OSA0Ljg1MzAzIDkuODg5NjkgMTAuODM5N0M5Ljg4OTY5IDE2LjgyNjQgMTQuNzQ2IDIxLjY3OTQgMjAuNzM2NyAyMS42Nzk0QzIyLjczNTkgMjEuNjc5NCAyNC42MTYyIDIyLjQ1NzMgMjYuMDI5OSAyMy44NzA3QzI3LjQ0MzYgMjUuMjgzNCAyOC4yMjI3IDI3LjE2MjQgMjguMjIyNyAyOS4xNjAzQzI4LjIyMjcgMzEuMTU4MiAyNy40NDQzIDMzLjAzNzIgMjYuMDI5OSAzNC40NDk5QzI0LjYxNjIgMzUuODYyNyAyMi43MzU5IDM2LjY0MTIgMjAuNzM2NyAzNi42NDEyQzE4LjczNzUgMzYuNjQxMiAxNi44NTcyIDM1Ljg2MzQgMTUuNDQzNSAzNC40NDk5QzE0LjAyOTggMzMuMDM3MiAxMy4yNTA3IDMxLjE1ODIgMTMuMjUwNyAyOS4xNjAzQzEzLjI1MDcgMjguNDYwNSAxMy4zNDY4IDI3Ljc3NTkgMTMuNTMyMSAyNy4xMjAzTDE1LjI4OCAyOC4xMjc1TDE1LjA5MDkgMjQuODMxNkwxNC44OTM5IDIxLjUzNTdMMTEuOTQ3IDIzLjAyODZMOSAyNC41MjE0TDEwLjU1NjggMjUuNDE0QzEwLjEyNjEgMjYuNTgxNSA5Ljg4OTY5IDI3Ljg0MjkgOS44ODk2OSAyOS4xNjAzQzkuODg5NjkgMzUuMTQ3IDE0Ljc0NiA0MCAyMC43MzY3IDQwQzI2LjcyNzQgNDAgMzEuNTgzNyAzNS4xNDcgMzEuNTgzNyAyOS4xNjAzQzMxLjU4MzcgMjUuMzA2MiAyOS41NzA3IDIxLjkyMTkgMjYuNTM4IDIwWk0yMC43MzY3IDE4LjMyMDZDMTguNzM3NSAxOC4zMjA2IDE2Ljg1NzIgMTcuNTQyNyAxNS40NDM1IDE2LjEyOTNDMTQuMDI5OCAxNC43MTY2IDEzLjI1MDcgMTIuODM3NiAxMy4yNTA3IDEwLjgzOTdDMTMuMjUwNyA4Ljg0MTg0IDE0LjAyOTEgNi45NjI4IDE1LjQ0MzUgNS41NTAwN0MxNi44NTcyIDQuMTM3MzQgMTguNzM3NSAzLjM1ODc4IDIwLjczNjcgMy4zNTg3OEMyMi43MzU5IDMuMzU4NzggMjQuNjE2MiA0LjEzNjY0IDI2LjAyOTkgNS41NTAwN0MyNy40NDM2IDYuOTYyOCAyOC4yMjI3IDguODQxODQgMjguMjIyNyAxMC44Mzk3QzI4LjIyMjcgMTIuODM3NiAyNy40NDQzIDE0LjcxNjYgMjYuMDI5OSAxNi4xMjkzQzI0LjYxNjIgMTcuNTQyMSAyMi43MzU5IDE4LjMyMDYgMjAuNzM2NyAxOC4zMjA2WiIgZmlsbD0id2hpdGUiPjwvcGF0aD4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8L3N2Zz4K"
      bff:
        env:
          BASE_ALLOWED_AUTH_HEADERS: user-agent,accept,content-type,origin,referer,accept-encoding,cookie,authorization
      clusters:
        - name: default
          description: default
          tenant: dev
          scheme: http
          {{- if $systemEnabled }}
          api: {{ $systemIstioGwVip }}
          {{- else }}
          api: 127.0.0.1
          {{- end }}
        - name: cluster2
          description: cluster2
          tenant: dev
          scheme: http
          api: 93.189.231.174   
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
            port: 4080
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
