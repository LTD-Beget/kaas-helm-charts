{{- define "in-cloud-capi-template.files.controllerManager.kubeControllerManagerJson.json" -}}
- path: /etc/kubernetes/patches/kube-controller-manager+json.json
  owner: root:root
  permissions: "0644"
  content: |
    [
      {
        "op": "add",
        "path": "/spec/containers/-",
        "value": {
          "name": "rbac-proxy",
          "image": "quay.io/brancz/kube-rbac-proxy:v0.21.0",
          "args": [
            "--secure-listen-address=0.0.0.0:11044",
            "--upstream=https://127.0.0.1:10257",
            "--tls-cert-file=/etc/kubernetes/pki/rbac-proxy-server.crt",
            "--tls-private-key-file=/etc/kubernetes/pki/rbac-proxy-server.key",
            "--kubeconfig=/etc/kubernetes/rbac-proxy.conf",
            "--auth-header-fields-enabled",
            "--v=2"
          ],
          "ports": [
            {
              "name": "https-metrics",
              "containerPort": 11044,
              "protocol": "TCP"
            }
          ],
          "volumeMounts": [
            {
              "name": "rbac-proxy-server-crt",
              "mountPath": "/etc/kubernetes/pki/rbac-proxy-server.crt",
              "readOnly": true
            },
            {
              "name": "rbac-proxy-server-key",
              "mountPath": "/etc/kubernetes/pki/rbac-proxy-server.key",
              "readOnly": true
            },
            {
              "name": "rbac-proxy-client-crt",
              "mountPath": "/etc/kubernetes/pki/rbac-proxy-client.crt",
              "readOnly": true
            },
            {
              "name": "rbac-proxy-client-key",
              "mountPath": "/etc/kubernetes/pki/rbac-proxy-client.key",
              "readOnly": true
            },
            {
              "name": "rbac-proxy-kubeconfig",
              "mountPath": "/etc/kubernetes/rbac-proxy.conf",
              "readOnly": true
            },
            {
              "name": "kube-ca",
              "mountPath": "/etc/kubernetes/pki/ca.crt",
              "readOnly": true
            }
          ]
        }
      },
      {
        "op": "add",
        "path": "/spec/volumes/-",
        "value": {
          "name": "kube-ca",
          "hostPath": {
            "path": "/etc/kubernetes/pki/ca.crt",
            "type": "File"
          }
        }
      },
      {
        "op": "add",
        "path": "/spec/volumes/-",
        "value": {
          "name": "rbac-proxy-server-crt",
          "hostPath": {
            "path": "/etc/kubernetes/pki/rbac-proxy-server.crt",
            "type": "File"
          }
        }
      },
      {
        "op": "add",
        "path": "/spec/volumes/-",
        "value": {
          "name": "rbac-proxy-server-key",
          "hostPath": {
            "path": "/etc/kubernetes/pki/rbac-proxy-server.key",
            "type": "File"
          }
        }
      },
      {
        "op": "add",
        "path": "/spec/volumes/-",
        "value": {
          "name": "rbac-proxy-client-crt",
          "hostPath": {
            "path": "/etc/kubernetes/pki/rbac-proxy-client.crt",
            "type": "File"
          }
        }
      },
      {
        "op": "add",
        "path": "/spec/volumes/-",
        "value": {
          "name": "rbac-proxy-client-key",
          "hostPath": {
            "path": "/etc/kubernetes/pki/rbac-proxy-client.key",
            "type": "File"
          }
        }
      },
      {
        "op": "add",
        "path": "/spec/volumes/-",
        "value": {
          "name": "rbac-proxy-kubeconfig",
          "hostPath": {
            "path": "/etc/kubernetes/rbac-proxy.conf",
            "type": "File"
          }
        }
      }
    ]
{{- end }}
