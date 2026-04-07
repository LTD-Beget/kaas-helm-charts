{{- define "in-cloud-capi-template.patches.machineTemplate.wrapper.customCp" -}}
  {{- with $.Values.capi.k8s -}}
    {{- $machineInfrastructureTemplate  := index .machineInfrastructureTemplate .infrastructureType }}
- selector:
    apiVersion: {{ $machineInfrastructureTemplate.apiVersion }}
    kind: {{ $machineInfrastructureTemplate.kind }}
    matchResources:
      controlPlane: true
  jsonPatches:
    - op: replace
      path: /spec/template/spec/networkTag
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpNetworkTag
    - op: replace
      path: /spec/template/spec/managedBy
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpManagedBy
    - op: replace
      path: /spec/template/spec/image
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpMasterImage
    - op: replace
      path: /spec/template/spec/serverName
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpServerName
    - op: replace
      path: /spec/template/spec/usePrivateNetwork
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpUsePrivateNetwork
    - op: replace
      path: /spec/template/spec/configuration/cpuCount
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpConfigurationCpucount
    - op: replace
      path: /spec/template/spec/configuration/diskSize
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpConfigurationDisksize
    - op: replace
      path: /spec/template/spec/configuration/memory
      valueFrom:
        variable: {{ $.Values.companyPrefix}}VmtCpConfigurationMemory
  {{- end -}}
{{- end -}}
