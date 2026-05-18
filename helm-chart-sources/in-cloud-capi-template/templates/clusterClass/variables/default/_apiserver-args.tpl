{{- define "in-cloud-capi-template.variables.default.apiserverArgs" -}}

- name: watchCache
  required: false
  schema:
    openAPIV3Schema:
      default: "false"
      type: string

- name: oidcIssuerUrl
  required: false
  schema:
    openAPIV3Schema:
      default: "https://dex.{{ $.Values.companyPrefix }}-dex.svc:5554"
      type: string
{{- end -}}