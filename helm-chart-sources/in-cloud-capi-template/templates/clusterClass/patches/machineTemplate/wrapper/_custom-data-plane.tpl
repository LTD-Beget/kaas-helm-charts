{{- define "in-cloud-capi-template.patches.machineTemplate.wrapper.customDp" -}}
  {{- with $.Values.capi.k8s -}}
    {{- $machineInfrastructureTemplate  := index .machineInfrastructureTemplate .infrastructureType }}
- selector:
    apiVersion: {{ $machineInfrastructureTemplate.apiVersion }}
    kind: {{ $machineInfrastructureTemplate.kind }}
    matchResources:
      machineDeploymentClass:
        names:
        - worker-class
  jsonPatches:
    - op: replace
      path: /spec/template/spec/configurationName
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtDpConfigurationName
    - op: replace
      path: /spec/template/spec/managedBy
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtDpManagedBy
    - op: replace
      path: /spec/template/spec/masterImage
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpMasterImage
    - op: replace
      path: /spec/template/spec/workerImage
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtDpWorkerImage
  {{- end -}}
{{- end -}}
