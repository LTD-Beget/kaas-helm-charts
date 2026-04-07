{{- define "in-cloud-capi-template.files.systemd.containerd-limits.conf" -}}
- path: /etc/systemd/system/containerd.service.d/limits.conf
  owner: root:root
  permissions: '0644'
  content: |
    # =============================================================================
    # /etc/systemd/system/containerd.service.d/limits.conf
    # Override лимитов для containerd — контейнерного рантайма K8s.
    #
    # Зачем отдельный override, если есть DefaultLimit* в system.conf.d?
    #   - Страховка: если systemd drop-in не скопирован, containerd всё равно
    #     получит правильные лимиты.
    #   - Явность: limits для ключевого сервиса видны прямо в его override,
    #     а не спрятаны в глобальных дефолтах.
    #   - Независимость: можно обновить глобальные дефолты, не сломав containerd.
    #
    # Установка:
    #   sudo mkdir -p /etc/systemd/system/containerd.service.d/
    #   sudo cp containerd-limits.conf /etc/systemd/system/containerd.service.d/limits.conf
    #   sudo systemctl daemon-reload
    #   sudo systemctl restart containerd
    #
    # Для CRI-O — аналогично:
    #   sudo mkdir -p /etc/systemd/system/crio.service.d/
    #   sudo cp containerd-limits.conf /etc/systemd/system/crio.service.d/limits.conf
    #
    # Проверка:
    #   systemctl show containerd -p LimitNOFILE -p LimitNPROC -p LimitMEMLOCK -p LimitCORE
    # =============================================================================

    [Service]

    # ─── LimitNOFILE ────────────────────────────────────────────────────────────
    # Открытые файлы / сокеты. Containerd держит FD на каждый контейнер,
    # snapshot'ы, gRPC-соединения к kubelet и shim'ам.
    #   2 GB:  реально ~500–2000 FD. Потолок 1M — страховка.
    #   32 GB: при 200+ Pod'ах — тысячи FD. 1M покрывает с запасом.
    LimitNOFILE=1048576

    # ─── LimitNPROC ─────────────────────────────────────────────────────────────
    # Процессы / потоки. Containerd порождает shim на каждый контейнер.
    #   2 GB:  ~30 Pod'ов × 1 shim = ~30 процессов. 65535 — с огромным запасом.
    #   32 GB: ~300 Pod'ов × 1 shim + потоки Go runtime — 65535 достаточно.
    LimitNPROC=65535

    # ─── LimitMEMLOCK ──────────────────────────────────────────────────────────
    # Заблокированная в RAM память. Containerd сам по себе mlock использует мало,
    # но дочерние процессы (runc, shim) могут наследовать лимит.
    # infinity — согласовано с Cilium (eBPF maps) и io_uring.
    LimitMEMLOCK=infinity

    # ─── LimitCORE ──────────────────────────────────────────────────────────────
    # Core dump отключён. Containerd-дамп содержит данные всех контейнеров,
    # включая секреты (env vars, mounted secrets). На production — 0.
    # Для отладки: временно LimitCORE=infinity + kernel.core_pattern.
    LimitCORE=0
{{- end }}
