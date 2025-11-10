{{- define "xclusterComponents.addonsetIii.ccm" -}}
  {{- printf `
ccm:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCcm
  namespace: {{ $customer }}
  version: v1alpha1
  releaseName: {{ $clusterName }}
  dependsOn:
  - helmInserter
  values:
    appSpec:
      applications:
        cloudControllerManager:
          containers:
            manager:
              extraArgs:
                v: 7
              image:
                tag: single-process
          imagePullSecrets:
          - name: regcred
          tolerations:
          - effect: NoExecute
            operator: Exists
          - key: node-role.kubernetes.io/control-plane
            operator: Exists
            effect: NoSchedule

  ` }}
{{- end -}}
