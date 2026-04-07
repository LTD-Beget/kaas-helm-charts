{{- define "in-cloud-capi-template.files.helm.downloadScript.sh" }}
    LOG_TAG="helm-installer"
    TMP_DIR="$(mktemp -d)"

    logger -t "$LOG_TAG" "[INFO] Checking current helm version..."

    CURRENT_VERSION=$($INSTALL_PATH version --short 2>/dev/null | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || true)
    if [[ -z "$CURRENT_VERSION" ]]; then CURRENT_VERSION="none"; fi

    COMPONENT_VERSION_CLEAN=$(echo "$COMPONENT_VERSION" | sed 's/^v//')

    logger -t "$LOG_TAG" "[INFO] Current: $CURRENT_VERSION, Target: $COMPONENT_VERSION_CLEAN"

    if [[ "$CURRENT_VERSION" != "$COMPONENT_VERSION_CLEAN" ]]; then
      logger -t "$LOG_TAG" "[INFO] Download URL: $PATH_BIN"
      logger -t "$LOG_TAG" "[INFO] Updating helm to version $COMPONENT_VERSION_CLEAN..."

      cd "$TMP_DIR"
      logger -t "$LOG_TAG" "[INFO] Working directory: $PWD"

      logger -t "$LOG_TAG" "[INFO] Downloading helm..."
      curl -fsSL -o "helm-${COMPONENT_VERSION}-linux-amd64.tar.gz" "$PATH_BIN" || { logger -t "$LOG_TAG" "[ERROR] Failed to download helm"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Downloading checksum file..."
      curl -fsSL -o "helm.sha256sum" "$PATH_SHA256" || { logger -t "$LOG_TAG" "[ERROR] Failed to download checksum file"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Verifying checksum..."
      sha256sum -c helm.sha256sum | grep 'OK' || { logger -t "$LOG_TAG" "[ERROR] Checksum verification failed!"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Extracting files..."
      tar -C "$TMP_DIR" -xvf "helm-${COMPONENT_VERSION}-linux-amd64.tar.gz"

      logger -t "$LOG_TAG" "[INFO] Installing binary..."
      install -m 755 "$TMP_DIR/linux-amd64/helm" "$INSTALL_PATH"

      logger -t "$LOG_TAG" "[INFO] Helm successfully updated to $COMPONENT_VERSION_CLEAN."
      rm -rf "$TMP_DIR"

    else
      logger -t "$LOG_TAG" "[INFO] Helm is already up to date. Skipping installation."
    fi
{{- end }}
