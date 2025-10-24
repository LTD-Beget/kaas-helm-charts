{{- define "xclusterComponents.addonsetIii.begetCmProvider" -}}
  {{- printf `
begetCmProvider:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsBegetCmProvider
  namespace: beget-cm-provider
  version: v1alpha1
  dependsOn: 
  - cilium
  values:
    appSpec:
      applications:
        providerBegetControllerManager:
          containers:
            manager:
              image:
                pullPolicy: Always
                tag: lb-name
          enabled: true
          tolerations:
          - effect: NoExecute
            operator: Exists
          - key: node-role.kubernetes.io/control-plane
            operator: Exists
            effect: NoSchedule
          imagePullSecrets:
            - name: regcred
  ` }}
{{- end -}}