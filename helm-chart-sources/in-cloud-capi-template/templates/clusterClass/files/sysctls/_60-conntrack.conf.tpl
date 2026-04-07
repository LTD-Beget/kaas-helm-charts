{{- define "in-cloud-capi-template.files.sysctls.60-conntrack.conf" -}}
- path: /etc/sysctl.d/60-conntrack.conf
  owner: root:root
  permissions: '0644'
  content: |
    # =============================================================================
    # CONNTRACK — таблица отслеживания соединений (NAT, iptables/nft, Docker, K8s)
    # Целевое ядро: Linux 6.x | Статичный конфиг для нод 2–32 GB RAM
    #
    # ОПЦИОНАЛЬНО: копировать ТОЛЬКО если загружен nf_conntrack.
    #   Проверка: lsmod | grep nf_conntrack
    #   Если модуля нет — sysctl выдаст ошибки.
    #
    # Установка:
    #   sudo cp 60-conntrack.conf /etc/sysctl.d/
    #   sudo sysctl --system
    # =============================================================================

    # Максимум записей в таблице conntrack.
    # При переполнении: "nf_conntrack: table full, dropping packet" в dmesg.
    # Мониторить: cat /proc/sys/net/netfilter/nf_conntrack_count
    #   2 GB:  262144 записей ≈ 40 MB (при ratio 1:1 с бакетами).
    #          Это ~2% RAM — безопасно. Покрывает ~260K одновременных соединений.
    #   32 GB: 262144 — консервативно. Можно 524288–1048576 (80–160 MB),
    #          но для единого конфига 262K достаточно на большинстве нод.
    #          При Cilium eBPF (kube-proxy replacement=strict) реальное потребление
    #          conntrack ниже — можно даже снизить до 131072.
    net.netfilter.nf_conntrack_max = 262144

    # Количество хэш-бакетов.
    # На ядрах >= 5.15 этот параметр read-only через sysctl — ядро само
    # рассчитывает его из nf_conntrack_max. Если нужно задать вручную,
    # используйте параметр модуля: echo 262144 > /sys/module/nf_conntrack/parameters/hashsize
    # При ratio 1:1 (buckets == max) — минимум коллизий, ~8 MB на таблицу при max=262144.
    # Оставляем закомментированным: ядро 6.x ставит оптимальное значение автоматически.
    # net.netfilter.nf_conntrack_buckets = 262144

    # nf_conntrack_helper УДАЛЁН в ядрах >= 6.0.
    # Автоматическое назначение ALG-helpers (FTP, SIP, …) отключено по умолчанию.
    # Если нужен конкретный helper — подключать явно через nft/iptables CT target.
    # net.netfilter.nf_conntrack_helper = 0
{{- end }}
