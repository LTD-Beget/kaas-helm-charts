{{- define "in-cloud-capi-template.variables.default.componentVariables" -}}
- name: containerdMirrorUrl
  required: false
  schema:
    openAPIV3Schema:
      default: "https://127.0.0.1:32443"
      type: string
{{- end -}}
