{{- define "clickhouseinserter.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: clickhouse-inserter
spec:
  rules:
    - name: cert-manager
      criteria:
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cert-manager{{ if eq .Values.environment "client" }}-client{{ end }}
          jsonPath: $.spec.variables.dependency
          operator: Equal
          value: "True"
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: trust-manager
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
      selector:
        name: cert-manager
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: cert-manager
          addons.in-cloud.io/addon: clickhouse-inserter-cert-manager
{{- end }}
