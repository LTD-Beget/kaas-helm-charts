{{- define "in-cloud-capi-template.variables.wrapper.infra.base" -}}

- name: {{ $.Values.companyPrefix}}VmtCpNetworkTag
  required: false
  schema:
    openAPIV3Schema:
      default: "vps"
      type: string

- name: {{ $.Values.companyPrefix}}VmtCpServerName
  required: false
  schema:
    openAPIV3Schema:
      default: ""
      type: string

- name: {{ $.Values.companyPrefix}}VmtCpUsePrivateNetwork
  required: false
  schema:
    openAPIV3Schema:
      default: true
      type: boolean

- name: {{ $.Values.companyPrefix}}VmtCpManagedBy
  required: true
  schema:
    openAPIV3Schema:
      default: "system"
      type: string

- name: {{ $.Values.companyPrefix}}VmtCpMasterImage
  required: false
  schema:
    openAPIV3Schema:
      default: "k8s-system:latest"
      type: string

- name: {{ $.Values.companyPrefix}}VmtDpWorkerImage
  required: false
  schema:
    openAPIV3Schema:
      default: "k8s-customer:latest"
      type: string

- name: {{ $.Values.companyPrefix}}VmtDpConfigurationName
  required: true
  schema:
    openAPIV3Schema:
      default: ""
      type: string

- name: {{ $.Values.companyPrefix}}VmtDpManagedBy
  required: true
  schema:
    openAPIV3Schema:
      default: "customer"
      type: string

- name: {{ $.Values.companyPrefix}}VmtCpConfigurationCpucount
  required: false
  schema:
    openAPIV3Schema:
      default: 4
      type: integer

- name: {{ $.Values.companyPrefix}}VmtCpConfigurationDisksize
  required: false
  schema:
    openAPIV3Schema:
      default: 92160
      type: integer

- name: {{ $.Values.companyPrefix}}VmtCpConfigurationMemory
  required: false
  schema:
    openAPIV3Schema:
      default: 8192
      type: integer


{{- end -}}
