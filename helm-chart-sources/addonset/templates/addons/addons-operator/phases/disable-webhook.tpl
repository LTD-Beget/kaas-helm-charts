{{- define "addonsoperator.phase.rules.disable-webhook" -}}
- name: disable-webhook
  criteria:
    - source:
        apiVersion: argoproj.io/v1alpha1
        kind: Application
        name: addonset
        namespace: {{ .Values.companyPrefix }}-argocd
      jsonPath: $.status.sync.status
      operator: NotEqual
      value: Synced
      keep: false
    - source:
        apiVersion: argoproj.io/v1alpha1
        kind: Application
        name: addonset
        namespace: {{ .Values.companyPrefix }}-argocd
      jsonPath: $.spec.syncPolicy.automated
      operator: Exists
      keep: false
  selector:
    name: disable-webhook
    priority: 80
    matchLabels:
      addons.in-cloud.io/values: disable-webhook
      addons.in-cloud.io/addon: {{ .Values.addonName }}
{{- end }}
