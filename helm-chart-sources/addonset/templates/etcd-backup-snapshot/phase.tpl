{{- define "etcd-backup-snapshot.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: etcd-backup-snapshot{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: infra
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{ end }}
            namespace: beget-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
      selector:
        name: infra
        priority: 10
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: etcd-backup-snapshot
{{- end }}

