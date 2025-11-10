{{- define "xclusterComponents.addonsetIii.csrc" -}}
  {{- printf `
csrc:
  apiVersion: in-cloud.io/v1alpha1
  kind: XAddonsCsrc
  namespace: {{ $customer }}
  version: v1alpha1
  releaseName: {{ $clusterName }}
  dependsOn:
  - helmInserter
  values:
    appSpec:
      applications:
        csrControllerManager:
          containers:
            manager:
              image:
                tag: rc1
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
