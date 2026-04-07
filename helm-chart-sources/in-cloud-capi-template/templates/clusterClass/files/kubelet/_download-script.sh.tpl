{{- define "in-cloud-capi-template.files.kubelet.downloadScript.sh" }}
    LOG_TAG="kubelet-installer"
    TMP_DIR="$(mktemp -d)"

    logger -t "$LOG_TAG" "[INFO] Checking current kubelet version..."

    CURRENT_VERSION=$($INSTALL_PATH --version 2>/dev/null | awk '{print $2}' | sed 's/v//') || CURRENT_VERSION="none"
    COMPONENT_VERSION_CLEAN=$(echo "$COMPONENT_VERSION" | sed 's/^v//')

    logger -t "$LOG_TAG" "[INFO] Current: $CURRENT_VERSION, Target: $COMPONENT_VERSION_CLEAN"

    if [[ "$CURRENT_VERSION" != "$COMPONENT_VERSION_CLEAN" ]]; then
      logger -t "$LOG_TAG" "[INFO] Download URL: $PATH_BIN"
      logger -t "$LOG_TAG" "[INFO] Updating kubelet to version $COMPONENT_VERSION_CLEAN..."

      cd "$TMP_DIR"
      logger -t "$LOG_TAG" "[INFO] Working directory: $PWD"

      logger -t "$LOG_TAG" "[INFO] Downloading kubelet..."
      curl -fsSL -o kubelet "$PATH_BIN" || { logger -t "$LOG_TAG" "[ERROR] Failed to download kubelet"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Downloading checksum file..."
      curl -fsSL -o kubelet.sha256sum "$PATH_SHA256" || { logger -t "$LOG_TAG" "[ERROR] Failed to download checksum file"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Verifying checksum..."
      awk '{print $1"  kubelet"}' kubelet.sha256sum | sha256sum -c - || { logger -t "$LOG_TAG" "[ERROR] Checksum verification failed!"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Installing kubelet..."
      install -m 755 kubelet "$INSTALL_PATH"

      logger -t "$LOG_TAG" "[INFO] kubelet successfully updated to $COMPONENT_VERSION_CLEAN."
      rm -rf "$TMP_DIR"

    else
      logger -t "$LOG_TAG" "[INFO] kubelet is already up to date. Skipping installation."
    fi
{{- end }}
