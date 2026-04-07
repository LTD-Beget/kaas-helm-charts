{{- define "in-cloud-capi-template.files.runc.downloadScript.sh" }}
    LOG_TAG="runc-installer"
    TMP_DIR="$(mktemp -d)"

    logger -t "$LOG_TAG" "[INFO] Checking current runc version..."

    CURRENT_VERSION=$($INSTALL_PATH --version 2>/dev/null | head -n1 | awk '{print $NF}') || CURRENT_VERSION="none"
    COMPONENT_VERSION_CLEAN=$(echo "$COMPONENT_VERSION" | sed 's/^v//')

    logger -t "$LOG_TAG" "[INFO] Current: $CURRENT_VERSION, Target: $COMPONENT_VERSION_CLEAN"

    if [[ "$CURRENT_VERSION" != "$COMPONENT_VERSION_CLEAN" ]]; then
      logger -t "$LOG_TAG" "[INFO] Download URL: $PATH_BIN"
      logger -t "$LOG_TAG" "[INFO] Updating runc to version $COMPONENT_VERSION..."

      cd "$TMP_DIR"
      logger -t "$LOG_TAG" "[INFO] Working directory: $PWD"

      logger -t "$LOG_TAG" "[INFO] Downloading runc..."
      curl -fsSL -o runc.amd64 "$PATH_BIN" || { logger -t "$LOG_TAG" "[ERROR] Failed to download runc"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Downloading checksum file..."
      curl -fsSL -o runc.sha256sum "$PATH_SHA256" || { logger -t "$LOG_TAG" "[ERROR] Failed to download checksum file"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Verifying checksum..."
      grep "runc.amd64" runc.sha256sum | sha256sum -c - || { logger -t "$LOG_TAG" "[ERROR] Checksum verification failed!"; exit 1; }

      logger -t "$LOG_TAG" "[INFO] Installing runc..."
      install -m 755 runc.amd64 "$INSTALL_PATH"

      logger -t "$LOG_TAG" "[INFO] runc successfully updated to $COMPONENT_VERSION."
      rm -rf "$TMP_DIR"

    else
      logger -t "$LOG_TAG" "[INFO] runc is already up to date. Skipping installation."
    fi
{{- end }}
