{{- define "in-cloud-capi-template.files.containerd.downloadScript.sh" }}
    LOG_TAG="containerd-installer"
    TMP_DIR="$(mktemp -d)"
    TARBALL="containerd-${COMPONENT_VERSION}-linux-amd64.tar.gz"

    CURRENT_VERSION="$($INSTALL_PATH/containerd --version 2>/dev/null | awk '{print $3}' | sed 's/^v//' || true)"
    CURRENT_VERSION="${CURRENT_VERSION:-none}"
    TARGET_VERSION="$(echo "$COMPONENT_VERSION" | sed 's/^v//')"
    TARGET_MAJOR="${TARGET_VERSION%%.*}"

    logger -t "$LOG_TAG" "[INFO] Current: $CURRENT_VERSION, Target: $TARGET_VERSION"

    # Cleanup legacy shims if running containerd v2+
    if [[ "$TARGET_MAJOR" -ge 2 ]]; then
      if [[ -f /usr/local/bin/containerd-shim || -f /usr/local/bin/containerd-shim-runc-v1 ]]; then
        logger -t "$LOG_TAG" "[INFO] Removing legacy containerd v1 shims"
        rm -f /usr/local/bin/containerd-shim
        rm -f /usr/local/bin/containerd-shim-runc-v1
      fi
    fi

    # Skip install if version already matches
    if [[ "$CURRENT_VERSION" == "$TARGET_VERSION" ]]; then
      logger -t "$LOG_TAG" "[INFO] Containerd already up to date. Skipping."
      exit 0
    fi

    logger -t "$LOG_TAG" "[INFO] Updating containerd..."

    cd "$TMP_DIR"

    logger -t "$LOG_TAG" "[INFO] Downloading containerd..."
    curl -fsSL -o "$TARBALL" "$PATH_BIN"

    logger -t "$LOG_TAG" "[INFO] Downloading checksum..."
    curl -fsSL -o sha256sum.txt "$PATH_SHA256"

    logger -t "$LOG_TAG" "[INFO] Verifying checksum..."
    grep "$TARBALL" sha256sum.txt | sha256sum -c -

    logger -t "$LOG_TAG" "[INFO] Extracting archive..."
    tar -xzf "$TARBALL"

    logger -t "$LOG_TAG" "[INFO] Installing binaries..."

    for bin in bin/*; do
      name="$(basename "$bin")"
      logger -t "$LOG_TAG" "[INFO] Installing $name"
      install -m 755 "$bin" "$INSTALL_PATH/$name"
    done

    rm -rf "$TMP_DIR"

    logger -t "$LOG_TAG" "[INFO] Containerd successfully updated to $TARGET_VERSION"
{{- end }}
