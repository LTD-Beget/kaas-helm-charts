{{- define "in-cloud-capi-template.variables.default.names" -}}
- name: externalClusterDomain
  required: false
  schema:
    openAPIV3Schema:
      default: internal
      type: string

- name: internalClusterDomain
  required: false
  schema:
    openAPIV3Schema:
      default: local
      type: string

- name: internalClusterName
  required: true
  schema:
    openAPIV3Schema:
      default: cluster
      type: string
{{- end -}}
