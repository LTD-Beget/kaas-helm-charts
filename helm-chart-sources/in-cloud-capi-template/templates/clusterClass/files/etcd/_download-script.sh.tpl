{{- define "in-cloud-capi-template.files.etcd.downloadScript.sh" }}
    LOG_TAG="etcd-installer"
    TMP_DIR="$(mktemp -d)"

    logger -t "$LOG_TAG" "[INFO] Checking current etcd version..."

    CURRENT_VERSION=$($INSTALL_PATH/etcd --version 2>/dev/null | grep 'etcd Version:' | awk '{print $3}' | sed 's/v//') || CURRENT_VERSION="none"
    COMPONENT_VERSION_CLEAN=$(echo "$COMPONENT_VERSION" | sed 's/^v//')

    logger -t "$LOG_TAG" "[INFO] Current: $CURRENT_VERSION, Target: $COMPONENT_VERSION_CLEAN"

    if [[ "$CURRENT_VERSION" != "$COMPONENT_VERSION_CLEAN" ]]; then
      logger -t "$LOG_TAG" "[INFO] Download URL: $PATH_BIN"
      logger -t "$LOG_TAG" "[INFO] Updating etcd to version $COMPONENT_VERSION_CLEAN..."

      cd "$TMP_DIR"
      logger -t "$LOG_TAG" "[INFO] Working directory: $PWD"

      logger -t "$LOG_TAG" "[INFO] Downloading etcd..."
      curl -fsSL -o "etcd-${COMPONENT_VERSION}-linux-amd64.tar.gz" "$PATH_BIN" || { logger -t "$LOG_TAG" "[ERROR] Failed to download etcd"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Downloading checksum file..."
      curl -fsSL -o "etcd.sha256sum" "$PATH_SHA256" || { logger -t "$LOG_TAG" "[ERROR] Failed to download checksum file"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Verifying checksum..."
      grep "etcd-${COMPONENT_VERSION}-linux-amd64.tar.gz" etcd.sha256sum | sha256sum -c - || { logger -t "$LOG_TAG" "[ERROR] Checksum verification failed!"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Extracting files..."
      tar -C "$TMP_DIR" -xvf "etcd-${COMPONENT_VERSION}-linux-amd64.tar.gz"

      logger -t "$LOG_TAG" "[INFO] Installing binaries..."
      install -m 755 "$TMP_DIR/etcd-${COMPONENT_VERSION}-linux-amd64/etcd" $INSTALL_PATH
      install -m 755 "$TMP_DIR/etcd-${COMPONENT_VERSION}-linux-amd64/etcdctl" $INSTALL_PATH
      install -m 755 "$TMP_DIR/etcd-${COMPONENT_VERSION}-linux-amd64/etcdutl" $INSTALL_PATH

      logger -t "$LOG_TAG" "[INFO] etcd successfully updated to $COMPONENT_VERSION_CLEAN."
      rm -rf "$TMP_DIR"

    else
      logger -t "$LOG_TAG" "[INFO] etcd is already up to date. Skipping installation."
    fi
{{- end }}
