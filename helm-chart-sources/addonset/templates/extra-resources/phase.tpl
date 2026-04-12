{{- define "extra-resources.phase" }}
---
apiVersion: addons.in-cloud.io/v1alpha1
kind: AddonPhase
metadata:
  name: extra-resources{{ if eq .Values.environment "client" }}-client{{ end }}
spec:
  rules:
    - name: infra
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "false"
          keep: false
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
      selector:
        name: infra
        priority: 20
        matchLabels:
          addons.in-cloud.io/values: infra
          addons.in-cloud.io/addon: extra-resources
    - name: client
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "false"
          keep: false
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "client"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
      selector:
        name: client
        priority: 30
        matchLabels:
          addons.in-cloud.io/values: client
          addons.in-cloud.io/addon: extra-resources
    - name: system
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "true"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
      selector:
        name: system
        priority: 40
        matchLabels:
          addons.in-cloud.io/values: system
          addons.in-cloud.io/addon: extra-resources
    - name: system-migrated
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters{{ if eq .Values.environment "client" }}-client{{else}}-infra{{ end }}
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.systemEnabled
          operator: Equal
          value: "true"
          keep: false
        - source:
            apiVersion: v1
            kind: Secret
            name: {{ if eq .Values.environment "client" }}{{ .Values.clientName }}{{ else }}{{ .Values.clusterName }}{{ end }}-ca
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.metadata.annotations['secret-copy.in-cloud.io/copiedAt']
          operator: Exists
        - source:
            apiVersion: clusterclaim.in-cloud.io/v1alpha1
            kind: ClusterClaim
            name: {{ .Values.clusterClaim }}
            namespace: {{ .Values.companyPrefix }}-system
          keep: false
          jsonPath: $.metadata.uid
          operator: Exists
      selector:
        name: system-migrated
        priority: 50
        matchLabels:
          addons.in-cloud.io/values: system-migrated
          addons.in-cloud.io/addon: extra-resources

    {{- if eq .Values.environment "infra" }}
    - name: network-policies-argocd
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters-infra
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: argocd
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cilium
          jsonPath: $.status.deployed
          operator: Equal
          value: true
          keep: false
        # TODO политику нужно отключить после добавления целевых политик
        # добавить критерий
        {{- if eq .Values.environment "infra" }}
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: AddonPhase
            name: argocd
          jsonPath: $.status.ruleStatuses[?(@.name=='network-policies')].deployed
          operator: NotExists
          # value: false
        {{- end }}
      selector:
        name: network-policies-argocd
        priority: 55
        matchLabels:
          addons.in-cloud.io/values: network-policies-argocd
          addons.in-cloud.io/addon: extra-resources
    {{- end }}

    {{- if eq .Values.environment "infra" }}
    - name: cluster-network-policies
      criteria:
        - source:
            apiVersion: v1
            kind: ConfigMap
            name: parameters-infra
            namespace: {{ .Values.companyPrefix }}-system
          jsonPath: $.data.environment
          operator: Equal
          value: "infra"
          keep: false
        - source:
            apiVersion: addons.in-cloud.io/v1alpha1
            kind: Addon
            name: cilium
          jsonPath: $.status.phaseValuesSelector[?(@.name=='enforcement-always')]
          operator: Exists
      selector:
        name: cluster-network-policies
        priority: 57
        matchLabels:
          addons.in-cloud.io/values: network-policies
          addons.in-cloud.io/addon: cluster-network-policies
    {{- end }}
{{- end }}
