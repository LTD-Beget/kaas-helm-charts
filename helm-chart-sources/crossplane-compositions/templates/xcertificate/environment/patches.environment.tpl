{{- define "xcertificate.environment.patches" -}}
  {{- $doc  := include "xcertificate.variables.template" . | fromYaml -}}
  {{- $vars := $doc.vars -}}

- toFieldPath: base.name
  fromFieldPath: metadata.name
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
  type: FromCompositeFieldPath
  {{- if eq $typ "string" }}
  transforms:
    - type: string
      string:
        type: Format
        fmt: {{ $fmt | quote }}
  {{- end }}
{{- end }}
{{- end -}}
