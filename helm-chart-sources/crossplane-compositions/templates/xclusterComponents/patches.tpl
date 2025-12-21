{{- define "xclusterComponents.environment.patches" -}}
  {{- $doc  := include "xclusterComponents.variables.template" . | fromYaml -}}
  {{- $vars := $doc.vars -}}

- toFieldPath: base.name
  fromFieldPath: metadata.name
  type: FromCompositeFieldPath

- toFieldPath: base.namespace
  fromFieldPath: spec.namespace
  type: FromCompositeFieldPath

- toFieldPath: base.customer
  fromFieldPath: spec.customer
  type: FromCompositeFieldPath

{{- range $name, $v := $vars }}
{{  $src := index $v 1 }}
  {{- $dst := index $v 2 }}
  {{- $typ  := printf "%v" (index $v 3) }}
  {{- $fmt  := index $v 4 }}
- toFieldPath: {{ $dst }}
  fromFieldPath: spec.{{ $src }}
  {{ if eq $typ "string" }}
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ $fmt | quote }}
  {{ end }}
  type: FromCompositeFieldPath
{{- end }}
{{- end -}}
