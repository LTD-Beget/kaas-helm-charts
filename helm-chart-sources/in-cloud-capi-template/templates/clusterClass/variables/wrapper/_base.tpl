{{- define "in-cloud-capi-template.variables.wrapper.base" -}}

- name: {{ $.Values.companyPrefix}}ClusterClaimName
  required: true
  schema:
    openAPIV3Schema:
      type: string

- name: {{ $.Values.companyPrefix}}ClusterRegion
  required: true
  schema:
    openAPIV3Schema:
      default: "ru1"
      type: string

- name: {{ $.Values.companyPrefix}}ClusterCustomerLogin
  required: true
  schema:
    openAPIV3Schema:
      default: ""
      type: string

{{- end -}}
