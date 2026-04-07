{{- define "in-cloud-capi-template.files.systemd.limits.conf" -}}
- path: /etc/systemd/system.conf.d/limits.conf
  owner: root:root
  permissions: '0644'
  content: |
    # =============================================================================
    # /etc/systemd/system.conf.d/limits.conf
    # Дефолтные лимиты для ВСЕХ systemd unit'ов (сервисов, таймеров и т.д.).
    # Минимум: 1 CPU / 2 GB RAM
    #
    # Установка:
    #   sudo mkdir -p /etc/systemd/system.conf.d
    #   sudo cp limits.conf /etc/systemd/system.conf.d/
    #   sudo systemctl daemon-reexec
    #
    # Эти значения — ДЕФОЛТ; конкретный сервис может переопределить их
    # в своём unit-файле через LimitNOFILE=, LimitNPROC= и т.д.
    #
    # Проверка для сервиса:
    #   systemctl show nginx.service -p LimitNOFILE LimitNPROC LimitMEMLOCK LimitCORE
    #
    # Проверка глобальных дефолтов:
    #   systemctl show -p DefaultLimitNOFILE -p DefaultLimitNPROC \
    #                  -p DefaultLimitMEMLOCK -p DefaultLimitCORE
    # =============================================================================

    [Manager]

    # ─── DefaultLimitNOFILE ─────────────────────────────────────────────────────
    #
    # Что:    потолок открытых файлов/сокетов для каждого systemd-сервиса.
    #
    # Дефолт systemd: soft=1024, hard=524288
    #   • soft=1024 — главная проблема: любой сервис, не прописавший
    #     LimitNOFILE= в unit-файле, стартует с лимитом в 1024 FD.
    #     Nginx, PostgreSQL, Redis при 1000+ соединениях упадут с
    #     «Too many open files».
    #   • hard=524288 — достаточно, но не согласовано с limits.d (1048576).
    #
    # Целевое: 1048576 (ставит и soft, и hard одинаково)
    #
    # Аргументация:
    #   - Согласовано с /etc/security/limits.d/90-high-load.conf и fs.nr_open.
    #   - Каждый FD ≈ 240 байт — 10K реально открытых = 2.4 MB. Неиспользованные
    #     FD не потребляют ни RAM, ни CPU. Высокий лимит — бесплатная страховка.
    #   - Устраняет необходимость прописывать LimitNOFILE= в каждом unit-файле.
    #
    # Импакт:
    #   + «Too many open files» больше не возникает на ровном месте
    #   + Все сервисы получают одинаковый высокий потолок без ручной настройки
    #   − Маскирует утечку FD — мониторить: cat /proc/<pid>/fdinfo | wc -l
    DefaultLimitNOFILE=1048576

    # ─── DefaultLimitNPROC ──────────────────────────────────────────────────────
    #
    # Что:    макс. процессов/потоков для каждого systemd-сервиса (по UID).
    #
    # Дефолт systemd: наследует kernel threads-max/2 ≈ 63814 (на 2 GB RAM)
    #   • Значение плавает в зависимости от RAM — не воспроизводимо.
    #
    # Целевое: 65535
    #
    # Аргументация:
    #   - Фиксирует лимит явно, чтобы на машинах с разным объёмом RAM
    #     поведение было предсказуемым.
    #   - 65535 — покрывает Go-сервисы (тысячи goroutine), Java thread pool,
    #     containerd + shim'ы на ноде.
    #   - Защита от fork-бомбы: при утечке один сервис не съест все PID.
    #
    # Импакт:
    #   + Предсказуемый лимит на любом железе
    #   + Защита от fork-бомбы со стороны сервисов
    #   − При 500+ контейнерах на ноде может потребоваться 131072
    DefaultLimitNPROC=65535

    # ─── DefaultLimitMEMLOCK ────────────────────────────────────────────────────
    #
    # Что:    макс. объём памяти, который сервис может заблокировать в RAM (mlock).
    #
    # Дефолт systemd: 8388608 байт (8 MB) — или 65536 (64 KB) на старых дистрибутивах
    #   На вашей машине: 8388608 (8 MB)
    #
    # Целевое: infinity
    #
    # Аргументация:
    #   - Cilium (eBPF) загружает BPF-карты через mmap + MAP_LOCKED.
    #     Типичное потребление: 50–300 MB. При лимите 8 MB → EPERM → Cilium
    #     не стартует, Pod'ы теряют сеть.
    #   - io_uring: IORING_REGISTER_BUFFERS блокирует страницы. 8 MB — мало
    #     для высоконагруженного I/O.
    #   - containerd, runc — тоже используют mlock для security-критичных данных.
    #   - infinity не значит «расходовать всю RAM». Процесс блокирует только то,
    #     что явно запросил. Реальное ограничение: cgroup MemoryMax.
    #
    # Импакт:
    #   + Cilium/eBPF работает без EPERM
    #   + io_uring, DPDK, GPU-direct не упираются в лимит
    #   − Контролировать реальное потребление через cgroup (MemoryMax)
    DefaultLimitMEMLOCK=infinity

    # ─── DefaultLimitCORE ───────────────────────────────────────────────────────
    #
    # Что:    макс. размер core dump для systemd-сервисов.
    #
    # Дефолт systemd: soft=0, hard=infinity
    #   • soft=0 — дамп не создаётся по умолчанию, но сервис может
    #     поднять лимит сам через setrlimit() и записать дамп любого размера.
    #   • hard=infinity — любой сервис может включить дампы самостоятельно.
    #
    # Целевое: 0 (и soft, и hard)
    #
    # Аргументация:
    #   - Core dump содержит полный дамп памяти процесса: пароли БД, JWT-секреты,
    #     TLS-ключи, PII пользователей — всё в открытом виде на диске.
    #   - Дамп Java-процесса с 1 GB heap = 1 GB файл. На диске 20 GB это
    #     может заполнить partition и вызвать каскадный отказ.
    #   - hard=0 гарантирует, что даже если сервис явно вызовет
    #     setrlimit(RLIMIT_CORE, unlimited) — ядро откажет.
    #   - Для отладки конкретного сервиса: systemctl edit myservice
    #     → [Service]\nLimitCORE=infinity + kernel.core_pattern
    #
    # Импакт:
    #   + Нет утечки секретов через аварийные дампы
    #   + Нет риска заполнения диска
    #   − Отладка segfault требует ручного включения для конкретного сервиса
    DefaultLimitCORE=0
{{- end }}
