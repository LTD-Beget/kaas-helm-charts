{{- define "in-cloud-capi-template.variables.default.networks" -}}
- name: clusterPodCidr
  required: false
  schema:
    openAPIV3Schema:
      default: "10.0.0.0/16"
      type: string

- name: clusterPodCidrMaskSize
  required: false
  schema:
    openAPIV3Schema:
      default: "24"
      type: string

- name: clusterServiceSubnet
  required: false
  schema:
    openAPIV3Schema:
      default: 29.64.0.0/16
      type: string

- name: clusterDnsSvc
  required: false
  schema:
    openAPIV3Schema:
      default: 29.64.0.10
      type: string
{{- end -}}
