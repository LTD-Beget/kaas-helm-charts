{{- define "addons.grafana" }}
name: Grafana
debug: false
path: helm-chart-sources/grafana
repoURL: https://github.com/LTD-Beget/kaas-helm-charts
targetRevision: HEAD
default: |
  grafana:
    name: grafana
    labels:
      app.kubernetes.io/name: grafana
    spec:
      config:
        log:
          mode: "console"
        auth:
          disable_login_form: "false"
        security:
          admin_user: "admin"
          admin_password: "supersecret"
      deployment:
        spec:
          template:
            spec:
              containers:
                - name: grafana
                  image: grafana/grafana:11.3.0
                  securityContext:
                    allowPrivilegeEscalation: true
                    readOnlyRootFilesystem: false
                  readinessProbe:
                    failureThreshold: 3
                  resources:
                    requests:
                      cpu: 100m
                      memory: 250Mi
                    limits:
                      cpu: 1
                      memory: 2Gi
{{- end }}
