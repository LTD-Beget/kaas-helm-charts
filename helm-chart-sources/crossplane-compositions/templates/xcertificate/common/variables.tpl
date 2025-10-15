#VariableName  DefaultValue  FromFieldPath  ToFieldPath  Type  Format
{{- define "xcertificate.variables.template" -}}
  {{- $vars := dict
    "commonAnnotations"               (list "(list)"                                  "common.annotations"                "common.annotations"                "list"    "-"                 )
    "commonLabels"                    (list "(list)"                                  "common.labels"                     "common.labels"                     "list"    "-"                 )
    "commonNamespace"                 (list "\"default\""                             "common.namespace"                  "common.namespace"                  "string"  "%s"                )
    "certificateAnnotations"          (list "(list)"                                  "certificate.annotations"           "certificate.annotations"           "list"    "-"                 )
    "certificateDnsNames"             (list "(list)"                                  "certificate.dnsNames"              "certificate.dnsNames"              "list"    "-"                 )
    "certificateCommonName"           (list "$certificateName"                        "certificate.commonName"            "certificate.commonName"            "string"  "%s"                )
    "certificateDuration"             (list "\"2160h\""                               "certificate.duration"              "certificate.duration"              "string"  "%s"                )
    "certificateIpAddresses"          (list "(list)"                                  "certificate.ipAddresses"           "certificate.ipAddresses"           "list"    "-"                 )
    "certificateIsCa"                 (list "false"                                   "certificate.isCA"                  "certificate.isCA"                  "bool"    "-"                 )
    "certificateLabels"               (list "(list)"                                  "certificate.labels"                "certificate.labels"                "list"    "-"                 )
    "certificateName"                 (list "$baseName"                               "certificate.name"                  "certificate.name"                  "string"  "%s"                )
    "certificateObjectName"           (list "(printf \"%s-certificate\" $baseName)"   "certificate.name"                  "certificate.object.name"           "string"  "%s-certificate"    )
    "certificateRenewBefore"          (list "\"720h\""                                "certificate.renewBefore"           "certificate.renewBefore"           "string"  "%s"                )
    "certificateRotationPolicy"       (list "\"Never\""                               "certificate.rotationPolicy"        "certificate.rotationPolicy"        "string"  "%s"                )
    "certificateSecretLabels"         (list "(list)"                                  "certificate.secret.labels"         "certificate.secret.labels"         "list"    "-"                 )
    "certificateSecretName"           (list "$certificateName"                        "certificate.secretName"            "certificate.secretName"            "string"  "%s"                )
    "certificateSubjectOrganizations" (list "(list)"                                  "certificate.subject.organizations" "certificate.subject.organizations" "list"    "-"                 )
    "certificateUsages"               (list "(list)"                                  "certificate.usages"                "certificate.usages"                "list"    "-"                 )
    "issuerAnnotations"               (list "(list)"                                  "issuer.annotations"                "issuer.annotations"                "list"    "-"                 )
    "issuerApiVersion"                (list "\"cert-manager.io/v1\""                  "issuer.apiVersion"                 "issuer.apiVersion"                 "string"  "%s"                )
    "issuerEnabled"                   (list "false"                                   "issuer.enabled"                    "issuer.enabled"                    "bool"    "-"                 )
    "issuerKind"                      (list "\"Issuer\""                              "issuer.kind"                       "issuer.kind"                       "string"  "%s"                )
    "issuerLabels"                    (list "(list)"                                  "issuer.labels"                     "issuer.labels"                     "list"    "-"                 )
    "issuerName"                      (list "$baseName"                               "issuer.name"                       "issuer.name"                       "string"  "%s"                )
    "issuerObjectName"                (list "(printf \"%s-issuer\" $baseName)"        "issuer.name"                       "issuer.object.name"                "string"  "%s-issuer"         )
    "issuerType"                      (list "\"selfsigned\""                          "issuer.type"                       "issuer.type"                       "string"  "%s"                )
    "issuerSignerAnnotations"         (list "(list)"                                  "issuerSigner.annotations"          "issuerSigner.annotations"          "list"    "-"                 )
    "issuerSignerApiVersion"          (list "\"cert-manager.io/v1\""                  "issuerSigner.apiVersion"           "issuerSigner.apiVersion"           "string"  "%s"                )
    "issuerSignerKind"                (list "\"Issuer\""                              "issuerSigner.kind"                 "issuerSigner.kind"                 "string"  "%s"                )
    "issuerSignerLabels"              (list "(list)"                                  "issuerSigner.labels"               "issuerSigner.labels"               "list"    "-"                 )
    "issuerSignerName"                (list "(printf \"%s-signer\" $baseName)"        "issuerSigner.name"                 "issuerSigner.name"                 "string"  "%s"                )
    "issuerSignerObjectName"          (list "(printf \"%s-issuer-signer\" $baseName)" "issuerSigner.name"                 "issuerSigner.object.name"          "string"  "%s-issuer-signer"  )
    "issuerSignerType"                (list "\"selfsigned\""                          "issuerSigner.type"                 "issuerSigner.type"                 "string"  "%s"                )
    "providerConfigRefName"           (list "\"default\""                             "providerConfigRef.name"            "providerConfigRef.name"            "string"  "%s"                )
  -}}
  {{- $order := list
      "commonAnnotations"
      "commonLabels"
      "commonNamespace"
      "certificateName"
      "certificateCommonName"
      "certificateObjectName"
      "certificateSecretName"
      "certificateAnnotations"
      "certificateLabels"
      "certificateSecretLabels"
      "certificateDnsNames"
      "certificateIpAddresses"
      "certificateSubjectOrganizations"
      "certificateUsages"
      "certificateDuration"
      "certificateRenewBefore"
      "certificateRotationPolicy"
      "certificateIsCa"
      "issuerAnnotations"
      "issuerApiVersion"
      "issuerEnabled"
      "issuerKind"
      "issuerLabels"
      "issuerName"
      "issuerObjectName"
      "issuerType"
      "issuerSignerAnnotations"
      "issuerSignerApiVersion"
      "issuerSignerKind"
      "issuerSignerLabels"
      "issuerSignerName"
      "issuerSignerObjectName"
      "issuerSignerType"
      "providerConfigRefName"
  -}}
  {{- dict "vars" $vars "order" $order | toYaml -}}
{{- end -}}

{{- define "xcertificate.variables.emit" -}}
  {{- $doc  := include "xcertificate.variables.template" . | fromYaml -}}
  {{- $vars := $doc.vars -}}
  {{- range $name := $doc.order -}}
    {{- $v    := index $vars $name -}}
    {{- $def  := index $v 0 -}}
    {{- $dst  := index $v 2 -}}
{{ printf "{{- $%s := default %s $environment.%s -}}\n" $name $def $dst }}
  {{- end -}}
{{- end -}}

{{- define "xcertificate.variables" -}}
  {{ printf `{{- $environment                      := index .context "apiextensions.crossplane.io/environment" }}

{{- $baseCustomer                     :=                            $environment.base.customer }}
{{- $baseName                         :=                            $environment.base.name }}
  ` }}
  {{- include "xcertificate.variables.emit" . | nindent 0 }}
  {{- printf `
{{- $certificateAnnotations            = concat $commonAnnotations  $certificateAnnotations -}}
{{- $certificateLabels                 = concat $commonLabels       $certificateLabels -}}
{{- $certificateSecretLabels           = concat $commonLabels       $certificateSecretLabels -}}
{{- $issuerAnnotations                 = concat $commonAnnotations  $issuerAnnotations }}
{{- $issuerLabels                      = concat $commonLabels       $issuerLabels }}
{{- $issuerSignerAnnotations           = concat $commonAnnotations  $issuerSignerAnnotations }}
{{- $issuerSignerLabels                = concat $commonLabels       $issuerSignerLabels }}

{{- $certificateReady                 := "False" }}
{{- $issuerReady                      := "False" }}
{{- $issuerSignerReady                := "False" }}

{{- with .observed.resources.certificate }}
  {{- range (dig "resource" "status" "atProvider" "manifest" "status" "conditions" (list) .) }}
    {{- if eq .type "Ready" }}
      {{- $certificateReady = (.status) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- with .observed.resources.issuer }}
  {{- range (dig "resource" "status" "atProvider" "manifest" "status" "conditions" (list) .) }}
    {{- if eq .type "Ready" }}
      {{- $issuerReady = (.status) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- with .observed.resources.issuerSigner }}
  {{- range (dig "resource" "status" "atProvider" "manifest" "status" "conditions" (list) .) }}
    {{- if eq .type "Ready" }}
      {{- $issuerSignerReady = (.status) }}
    {{- end }}
  {{- end }}
{{- end }}

  ` }}
{{- end -}}
