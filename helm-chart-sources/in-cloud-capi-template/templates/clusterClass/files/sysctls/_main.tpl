{{- define "in-cloud-capi-template.files.sysctls.aggregate" -}}
    {{ (include "in-cloud-capi-template.files.sysctls.40-security.conf"       $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.sysctls.60-conntrack.conf"      $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.sysctls.60-memory-disk.conf"    $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.sysctls.60-network.conf"        $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.sysctls.99-br-netfilter.conf"   $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.sysctls.99-inotify.conf"        $ | nindent 0  ) }}
    {{ (include "in-cloud-capi-template.files.sysctls.99-network.conf"        $ | nindent 0  ) }}
{{- end -}}
