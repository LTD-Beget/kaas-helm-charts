#VariableName  DefaultValue  FromFieldPath  ToFieldPath  Type  Format
{{- define "xclusterComponents.variables.template" -}}
  {{- $vars := dict
    "argocdDestinationName"               (list "\"mock\""       "argocd.destination.name"                "argocd.destination.name"              "string"           "%s"  )
    "argocdDestinationNamespace"          (list "\"mock\""       "argocd.destination.namespace"           "argocd.destination.namespace"         "string"           "%s"  )
    "argocdDestinationProject"            (list "\"mock\""       "argocd.destination.project"             "argocd.destination.project"           "string"           "%s"  )
    "clientCa"                            (list "\"mock\""       "clientCa"                               "clientCa"                             "string"           "%s"  )
    "clusterName"                         (list "\"mock\""       "cluster.name"                           "cluster.name"                         "string"           "%s"  )
    "clusterClientName"                   (list "\"mock\""       "clusterClient.name"                     "clusterClient.name"                   "string"           "%s"  )
    "clusterHost"                         (list "\"mock\""       "cluster.host"                           "cluster.host"                         "string"           "%s"  )
    "clusterPort"                         (list "6443"           "cluster.port"                           "cluster.port"                         "integer"          "%s"  )
    "clusterClientPort"                   (list "26443"          "clusterClient.port"                     "clusterClient.port"                   "integer"          "%s"  )
    "controlPlaneReplicas"                (list "1"              "controlPlaneReplicas"                   "controlPlaneReplicas"                 "integer"          "%s"  )
    "systemEnabled"                       (list "false"          "system.enabled"                         "system.enabled"                       "boolean"          "%v"  )
    "trackingID"                          (list "\"mock\""       "trackingID"                             "trackingID"                           "string"           "%s"  )
    "xcluster"                            (list "\"mock\""       "xcluster"                               "xcluster"                             "string"           "%s"  )

    "argsDexStaticPasswordsAdmin"         (list "\"mock\""       "args.dexStaticPasswordsAdmin"           "args.dexStaticPasswordsAdmin"         "string"           "%s"  )
    "argsDexStaticClientsApiserver"       (list "\"mock\""       "args.dexStaticClientsApiserver"         "args.dexStaticClientsApiserver"       "string"           "%s"  )
    "argsEtcdbackupS3AccessKey"           (list "\"mock\""       "args.etcdbackupS3AccessKey"             "args.etcdbackupS3AccessKey"           "string"           "%s"  )
    "argsEtcdbackupS3SecretAccessKey"     (list "\"mock\""       "args.etcdbackupS3SecretAccessKey"       "args.etcdbackupS3SecretAccessKey"     "string"           "%s"  )
    "argsEtcdbackupS3SecretEndpoint"      (list "\"mock\""       "args.etcdbackupS3SecretEndpoint"        "args.etcdbackupS3SecretEndpoint"      "string"           "%s"  )
    "argsEtcdbackupAppArgsStorecontainer" (list "\"mock\""       "args.etcdbackupAppArgsStorecontainer"   "args.dexStaticClientsApiserver"       "string"           "%s"  )
    "argsIncloudUICookieSecret"           (list "\"mock\""       "args.incloudUICookieSecret"             "args.incloudUICookieSecret"           "string"           "%s"  )
    "argsGrafanaConfigAdminUser"          (list "\"mock\""       "args.grafanaConfigAdminUser"            "args.grafanaConfigAdminUser"          "string"           "%s"  )
    "argsGrafanaConfigAdminPassword"      (list "\"mock\""       "args.grafanaConfigAdminPassword"        "args.grafanaConfigAdminPassword"      "string"           "%s"  )
    "argsGrafanaDeploymentEnvOidcSecret"  (list "\"mock\""       "args.grafanaDeploymentEnvOidcSecret"    "args.grafanaDeploymentEnvOidcSecret"  "string"           "%s"  )

  -}}
  {{- $order := list
    "argocdDestinationName"
    "argocdDestinationNamespace"
    "argocdDestinationProject"
    "clientCa"
    "clusterName"
    "clusterClientName"
    "clusterHost"
    "clusterPort"
    "clusterClientPort"
    "controlPlaneReplicas"
    "systemEnabled"
    "trackingID"
    "xcluster"
    "argsDexStaticPasswordsAdmin"
    "argsDexStaticClientsApiserver"
    "argsEtcdbackupS3AccessKey"
    "argsEtcdbackupS3SecretAccessKey"
    "argsEtcdbackupS3SecretEndpoint"
    "argsEtcdbackupAppArgsStorecontainer"
    "argsIncloudUICookieSecret"
    "argsGrafanaConfigAdminUser"
    "argsGrafanaConfigAdminPassword"
    "argsGrafanaDeploymentEnvOidcSecret"
  -}}
  {{- dict "vars" $vars "order" $order | toYaml -}}
{{- end -}}

{{- define "xclusterComponents.variables.emit" -}}
  {{- $doc  := include "xclusterComponents.variables.template" . | fromYaml -}}
  {{- $vars := $doc.vars -}}
  {{- range $name := $doc.order -}}
    {{- $v    := index $vars $name -}}
    {{- $def  := index $v 0 -}}
    {{- $dst  := index $v 2 -}}
{{ printf "{{- $%s := default %s $environment.%s -}}\n" $name $def $dst }}
  {{- end -}}
{{- end -}}

{{- define "xclusterComponents.variables" -}}
  {{ printf `{{- $environment                      := index .context "apiextensions.crossplane.io/environment" }}

{{- $customer                          :=                            $environment.base.customer }}
{{- $name                              :=                            $environment.base.name }}
  ` }}
  {{- include "xclusterComponents.variables.emit" . | nindent 0 }}

{{- end -}}
