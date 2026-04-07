{{- define "in-cloud-capi-template.files.sysctls.40-security.conf" -}}
- path: /etc/sysctl.d/40-security.conf
  owner: root:root
  permissions: '0644'
  content: |
    # =============================================================================
    # БЕЗОПАСНОСТЬ — hardening ядра и сетевого стека
    # Целевое ядро: Linux 6.x | Минимум: 1 CPU / 2 GB RAM
    #
    # Установка:
    #   sudo cp 40-security.conf /etc/sysctl.d/
    #   sudo sysctl --system
    # =============================================================================


    # ─── Сеть IPv4: защита от спуфинга и перенаправлений ───────────────────────

    # Reverse Path Filtering: дропать пакеты, src которых не маршрутизируется
    # обратно через тот же (strict=1) или любой (loose=2) интерфейс.
    #
    # ⚠ CILIUM: Cilium при старте СБРАСЫВАЕТ conf.all.rp_filter в 0
    #   (файл /etc/sysctl.d/99-zzz-override_cilium.conf), потому что ядро
    #   вычисляет rp_filter = max(conf.all, conf.{dev}).
    #   Если conf.all=1, то даже conf.lxc*.rp_filter=0 не поможет — трафик подов дропается.
    #
    #   На ноде с Cilium: оставьте conf.default.rp_filter = 1 (новые НЕ-Cilium интерфейсы
    #   получат strict), а conf.all — НЕ СТАВЬТЕ (Cilium управляет сам).
    #   На ноде БЕЗ Cilium: раскомментируйте conf.all.
    #
    # net.ipv4.conf.all.rp_filter = 1
    net.ipv4.conf.default.rp_filter = 1

    # Не принимать ICMP redirects — защита от MitM через подмену маршрута.
    net.ipv4.conf.all.accept_redirects = 0
    net.ipv4.conf.default.accept_redirects = 0

    # Не отправлять ICMP redirects другим хостам.
    net.ipv4.conf.all.send_redirects = 0
    net.ipv4.conf.default.send_redirects = 0

    # Не принимать пакеты с source routing (произвольный маршрут в заголовке).
    net.ipv4.conf.all.accept_source_route = 0
    net.ipv4.conf.default.accept_source_route = 0

    # Игнорировать ICMP echo на broadcast-адреса (защита от Smurf-атаки).
    net.ipv4.icmp_echo_ignore_broadcasts = 1


    # ─── Сеть IPv6: симметрия с IPv4 ──────────────────────────────────────────

    # Не принимать ICMPv6 redirects.
    net.ipv6.conf.all.accept_redirects = 0
    net.ipv6.conf.default.accept_redirects = 0

    # Не принимать IPv6 source routing.
    net.ipv6.conf.all.accept_source_route = 0
    net.ipv6.conf.default.accept_source_route = 0


    # ─── Файловая система ─────────────────────────────────────────────────────

    # Запретить создание hardlink/symlink на файлы, не принадлежащие пользователю.
    # Защита от класса symlink/hardlink-атак на /tmp и shared-каталоги.
    fs.protected_hardlinks = 1
    fs.protected_symlinks = 1


    # ─── Ядро ──────────────────────────────────────────────────────────────────

    # Скрыть адреса ядра из /proc/kallsyms и %pK-формата для непривилегированных.
    # 2 = полностью скрыть (даже от CAP_SYSLOG без CAP_SYS_ADMIN).
    # Импакт: усложняет эксплуатацию уязвимостей ядра.
    kernel.kptr_restrict = 2

    # Доступ к dmesg (логам ядра) только для root.
    # Импакт: утечка информации о ядре/адресах для непривилегированных пользователей.
    kernel.dmesg_restrict = 1

    # Запретить непривилегированным пользователям загружать BPF-программы.
    # Привилегированные процессы (Cilium, bpftrace и т.д.) не затронуты.
    # Импакт: закрывает вектор атак через eBPF из userspace.
    kernel.unprivileged_bpf_disabled = 1

    # Запретить непривилегированный userfaultfd (используется в некоторых эксплойтах ядра).
    vm.unprivileged_userfaultfd = 0
{{- end }}
