# dmkolbin/argocd-with-utils:v2.14.10
FROM quay.io/argoproj/argocd:v2.14.10

ENV OS="linux" \
    ARCH="amd64" \
    BIN_PATH="/usr/local/bin" \
    ARGOCD_VAULT_PLUGIN_VERSION="1.18.1" \
    YQ_VERSION="4.49.2"

ADD --chmod=755 https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${ARGOCD_VAULT_PLUGIN_VERSION}/argocd-vault-plugin_${ARGOCD_VAULT_PLUGIN_VERSION}_${OS}_${ARCH} ${BIN_PATH}/argocd-vault-plugin
ADD --chmod=755 https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_${OS}_${ARCH} ${BIN_PATH}/yq
