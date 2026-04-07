{{- define "in-cloud-capi-template.files.bashrc.custom" -}}
- path: /root/.bashrc
  owner: root:root
  permissions: '0644'
  content: |
    # ~/.bashrc — Production Shell for Kubernetes Nodes
    # vim: set ft=bash ts=4 sw=4 et:
    #
    # Features:
    #   - Safe defaults (set -o pipefail in functions, umask 027)
    #   - Immutable history with timestamps and dedup
    #   - 256-color prompt with K8s context/namespace awareness
    #   - PROD detection from local cluster + namespace patterns
    #   - Colorized kubectl output (statuses, READY, AGE)
    #   - Safe delete with PROD confirmation
    #   - Tab completion for all kubectl aliases and helpers
    #   - Defensive coding: no unquoted expansions, all errors handled

    # ── Non-interactive bail-out ──────────────────────────────────────
    [[ $- != *i* ]] && return

    # ====================== SAFETY DEFAULTS ======================
    umask 027                        # rwxr-x--- for new files
    set -o pipefail 2>/dev/null      # catch errors in pipes (bash 4.4+)

    # ====================== SHELL OPTIONS ======================
    shopt -s checkwinsize            # update LINES/COLUMNS after each command
    shopt -s globstar 2>/dev/null    # ** matches recursively (bash 4.0+)
    shopt -s cdspell                 # autocorrect minor typos in cd
    shopt -s dirspell 2>/dev/null    # autocorrect typos in dir completion (bash 4.0+)
    shopt -s no_empty_cmd_completion # don't Tab-complete on empty line
    shopt -s extglob                 # extended globs: !(pattern), @(pattern)
    shopt -s histverify              # don't execute history expansion immediately, let user review
    shopt -s autocd 2>/dev/null      # type dir name to cd into it (bash 4.0+)
    set -o noclobber                 # prevent > from overwriting files (use >| to force)

    # ====================== HISTORY ======================
    HISTCONTROL=ignoreboth:erasedups
    shopt -s histappend
    shopt -s cmdhist                 # multiline commands as one entry
    shopt -s lithist                 # preserve newlines in multiline commands
    HISTSIZE=500000
    HISTFILESIZE=1000000
    HISTTIMEFORMAT='%F %T  '
    HISTIGNORE='ls:ll:la:l:cd:cd -:pwd:exit:clear:history:bg:fg:jobs'
    HISTIGNORE+=':*password*:*passwd*:*secret*:*token*:*apikey*:*API_KEY*'
    HISTIGNORE+=':*AWS_*=*:export *KEY*=*:export *SECRET*=*:export *TOKEN*=*'
    HISTIGNORE+=':*--kubeconfig*:*KUBECONFIG=*:*cert*key*:*-----BEGIN*'

    # Per-host history file (safe on shared NFS/home)
    HISTFILE="${HOME}/.bash_history_${HOSTNAME%%.*}"

    # Eternal history — append-only audit log (never truncated)
    # Format: #epoch USER HOST PWD EXIT_CODE COMMAND
    _log_eternal_history() {
        local _last
        _last=$(history 1)
        [[ -z "$_last" ]] && return
        local _cmd="${_last#*  }"       # strip history number + timestamp
        _cmd="${_cmd#*  }"              # strip timestamp added by HISTTIMEFORMAT
        printf '%s %s %s %s %d %s\n' \
            "#$(date +%s)" "${USER:-root}" "${HOSTNAME%%.*}" "$PWD" "${_LAST_EXIT:-0}" "$_cmd" \
            >> "${HOME}/.bash_eternal_history" 2>/dev/null
    }

    # Arrow keys search by prefix (type start of command, then Up/Down)
    bind '"\e[A": history-search-backward' 2>/dev/null
    bind '"\e[B": history-search-forward' 2>/dev/null

    # Capture exit codes for failed commands into eternal history
    trap '_LAST_EXIT=$?' ERR

    # ====================== ENVIRONMENT ======================
    export KUBECONFIG=/etc/kubernetes/admin.conf
    export EDITOR="${EDITOR:-vim}"
    export VISUAL="${VISUAL:-$EDITOR}"
    export PAGER="${PAGER:-less}"
    export LESS='-RFXi'              # Raw color, quit-if-one-screen, no-init, ignore-case
    export LANG="${LANG:-en_US.UTF-8}"
    export LC_ALL="${LC_ALL:-en_US.UTF-8}"
    [[ -z "$TMUX" && "$TERM" != "screen"* ]] && export TERM=xterm-256color
    export KUBECTL_EXTERNAL_DIFF="diff --color=always -u"
    export SYSTEMD_PAGER=""          # don't page systemctl output

    # XDG defaults (some tools respect these)
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

    # ====================== PATH ======================
    # Prepend local bin dirs if they exist (idempotent)
    _prepend_path() { [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"; }
    _prepend_path /usr/local/sbin
    _prepend_path /usr/local/bin
    _prepend_path "$HOME/.local/bin"
    _prepend_path "$HOME/bin"
    unset -f _prepend_path
    export PATH

    # ====================== CLUSTER DETECTION ======================
    _LOCAL_CLUSTER=""
    if [[ -f "$KUBECONFIG" ]]; then
        _LOCAL_CLUSTER=$(grep -m1 'current-context:' "$KUBECONFIG" 2>/dev/null | sed -E 's/.*@//')
    fi

    # Prod namespace patterns (extend as needed)
    _PROD_NS_REGEX='({{ $.Values.companyPrefix }})'

    # ====================== COLORS (prompt) ======================
    # Bright, bold palette — high contrast on dark terminals
    _C_RED="\[\e[1;38;5;196m\]"
    _C_GREEN="\[\e[1;38;5;82m\]"
    _C_YELLOW="\[\e[1;38;5;220m\]"
    _C_BLUE="\[\e[1;38;5;75m\]"
    _C_CYAN="\[\e[1;38;5;81m\]"
    _C_GRAY="\[\e[38;5;250m\]"
    _C_WHITE="\[\e[1;38;5;255m\]"
    _C_BG_PROD="\[\e[48;5;196m\]"
    _C_BG_NS="\[\e[48;5;25m\]"
    _C_RESET="\[\e[0m\]"
    _C_BOLD="\[\e[1m\]"

    # ====================== PROMPT ======================
    _is_prod_context() {
        [[ -n "$_LOCAL_CLUSTER" && "$1" == *"$_LOCAL_CLUSTER"* ]] || \
        [[ "$2" =~ $_PROD_NS_REGEX ]]
    }

    _update_ps1() {
        local rc=$?
        _LAST_EXIT=$rc

        # Write new entries to file immediately (survive crashes)
        # Not using history -c/-r — breaks erasedups deduplication
        history -a

        # Eternal audit log
        _log_eternal_history

        local ctx ns short_ctx
        ctx=$(kubectl config current-context 2>/dev/null)
        ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
        : "${ns:=default}"

        # Non-K8s fallback prompt
        if [[ -z "$ctx" ]]; then
            PS1="${_C_GREEN}\u@\h${_C_RESET} ${_C_BLUE}\w${_C_RESET} "
            (( rc != 0 )) && PS1+="${_C_RED}" || PS1+="${_C_GRAY}"
            PS1+="[${rc}]${_C_RESET} \$ "
            return
        fi

        short_ctx="${ctx##*@}"

        # Build prompt left-to-right
        if _is_prod_context "$ctx" "$ns"; then
            PS1="${_C_RED}${_C_RESET}${_C_BG_PROD}${_C_WHITE}${_C_BOLD} PROD: ${short_ctx} ${_C_RESET} "
        else
            PS1="${_C_CYAN}⎈ ${short_ctx}${_C_RESET} "
        fi

        PS1+="${_C_BG_NS}${_C_WHITE} ${ns} ${_C_RESET} "
        PS1+="${_C_GREEN}\u@\h${_C_RESET} ${_C_BLUE}\w${_C_RESET} "
        (( rc != 0 )) && PS1+="${_C_RED}" || PS1+="${_C_GREEN}"
        PS1+="[${rc}]${_C_RESET} \$ "
    }

    PROMPT_COMMAND="_update_ps1"

    # ====================== KUBECTL COLORIZER ======================
    kcolor() {
        awk '
        BEGIN {
            R   = "\033[1;38;5;196m"
            G   = "\033[1;38;5;82m"
            Y   = "\033[1;38;5;220m"
            C   = "\033[1;38;5;81m"
            DIM = "\033[38;5;245m"
            RST = "\033[0m"
            BLD = "\033[1;97m"
        }
        function colorize(w, col) {
            # READY column x/y
            if (w ~ /^[0-9]+\/[0-9]+$/) {
                split(w, p, "/")
                if (p[1] == p[2] && p[1]+0 > 0) return G w RST
                return R w RST
            }
            # Good statuses
            if (w ~ /^(Running|Completed|Succeeded|Active|Bound|Ready|True|Available|Healthy|Synced)$/)
                return G w RST
            # Bad statuses
            if (w ~ /^(CrashLoopBackOff|Error|Failed|Evicted|OOMKilled|ImagePullBackOff|ErrImagePull|ErrImageNeverPull|InvalidImageName|CreateContainerError|CreateContainerConfigError|Terminating|False|NotReady|Unavailable|BackOff|Degraded|OutOfSync|Missing|Unknown)$/)
                return R w RST
            # Transitional statuses
            if (w ~ /^(Pending|ContainerCreating|PodInitializing|Warning|Unschedulable|ContainerStatusUnknown|Progressing|Suspended)$/ || w ~ /^Init:/)
                return Y w RST
            # RESTARTS column (pure integer in data rows)
            if (w ~ /^[0-9]+$/ && col == restarts_col) {
                if (w+0 == 0) return DIM w RST
                if (w+0 <= 5) return Y w RST
                return R w RST
            }
            # AGE: fresh
            if (w ~ /^[0-9]+(s|ms)$/ || w ~ /^[0-9]+m[0-9]*s?$/ || w ~ /^[0-9]+h[0-9]*m?$/)
                return C w RST
            # AGE: days
            if (w ~ /^[0-9]+d$/) {
                v = w+0
                if (v <= 7) return G w RST
                if (v <= 30) return Y w RST
                return R w RST
            }
            # AGE: weeks/years — stale
            if (w ~ /^[0-9]+[wy]$/)
                return R w RST
            return w
        }
        NR == 1 {
            restarts_col = 0
            n = split($0, hdr)
            for (i = 1; i <= n; i++) {
                if (hdr[i] == "RESTARTS") { restarts_col = i; break }
            }
            printf "%s%s%s\n", BLD, $0, RST
            next
        }
        NR > 500 { print; next }
        {
            line = $0; result = ""; col = 0
            while (match(line, /[^ ]+/)) {
                col++
                result = result substr(line, 1, RSTART - 1)
                result = result colorize(substr(line, RSTART, RLENGTH), col)
                line = substr(line, RSTART + RLENGTH)
            }
            print result line
        }'
    }

    # ====================== GENERAL ALIASES ======================
    alias ls='ls --color=auto'
    alias ll='ls -alFh'
    alias la='ls -A'
    alias l='ls -CF'
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip -color=auto'
    alias dmesg='dmesg --color=auto -T'
    alias less='less -RFXi'
    alias tree='tree -C'
    alias df='df -hT'
    alias du='du -h'
    alias free='free -h'
    alias mount='mount | column -t'
    alias ports='ss -tulnp'
    alias connections='ss -tanp'
    alias path='echo "$PATH" | tr : "\n"'
    alias now='date "+%F %T %Z"'
    alias week='date +%V'
    alias reload='source ~/.bashrc'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias mkdir='mkdir -pv'
    alias wget='wget -c'

    # ====================== SYSTEM HELPERS ======================
    # Quick disk usage of current directory
    duf() { du -sh "${1:-.}"/* 2>/dev/null | sort -rh | head -20; }

    # Find largest files
    bigfiles() { find "${1:-.}" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -"${2:-20}"; }

    # Extract any archive
    extract() {
        [[ ! -f "$1" ]] && { echo "'$1' is not a file"; return 1; }
        case "$1" in
            *.tar.bz2) tar xjf "$1"    ;;
            *.tar.gz)  tar xzf "$1"    ;;
            *.tar.xz)  tar xJf "$1"    ;;
            *.bz2)     bunzip2 "$1"    ;;
            *.rar)     unrar x "$1"    ;;
            *.gz)      gunzip "$1"     ;;
            *.tar)     tar xf "$1"     ;;
            *.tbz2)    tar xjf "$1"    ;;
            *.tgz)     tar xzf "$1"    ;;
            *.zip)     unzip "$1"      ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1"       ;;
            *.xz)      xz -d "$1"      ;;
            *.zst)     zstd -d "$1"    ;;
            *)         echo "'$1': unknown archive format" ;;
        esac
    }

    # Quick HTTP server (python3)
    serve() { python3 -m http.server "${1:-8080}"; }

    # Repeat a command every N seconds
    repeat() {
        local interval="${1:-2}"; shift
        while true; do
            clear
            echo -e "\033[38;5;246m$(date '+%F %T') | every ${interval}s | $*\033[0m"
            echo ""
            "$@"
            sleep "$interval"
        done
    }

    # ====================== KUBECTL ALIASES ======================
    alias k='kubectl '
    unalias ka kaf ke 2>/dev/null
    alias kl='kubectl logs'
    alias klf='kubectl logs -f'
    alias kla='kubectl logs --all-containers=true --prefix'
    alias kx='kubectl exec -it'
    alias kpf='kubectl port-forward'
    alias ksc='kubectl scale'
    alias krd='kubectl rollout restart deployment'

    # ====================== KUBECTL FUNCTIONS ======================
    unalias kg ki cll kd 2>/dev/null

    kg()  { if [[ -t 1 ]]; then kubectl get "$@" 2>&1 | kcolor; else kubectl get "$@"; fi; }
    ki()  { if [[ -t 1 ]]; then kubectl describe "$@" 2>&1 | kcolor; else kubectl describe "$@"; fi; }
    cll() { if [[ -t 1 ]]; then kubectl config get-contexts "$@" 2>&1 | kcolor; else kubectl config get-contexts "$@"; fi; }

    kns() {
        if [[ -z "$1" ]]; then
            kubectl get namespaces 2>&1 | kcolor; return
        fi
        kubectl config set-context --current --namespace="$1" && \
            echo -e "\033[1;38;5;82m→ Namespace: $1\033[0m"
    }

    kctx() {
        if [[ -z "$1" ]]; then
            kubectl config get-contexts 2>&1 | kcolor; return
        fi
        kubectl config use-context "$1" && \
            echo -e "\033[1;38;5;82m→ Context: $1\033[0m"
    }

    kexec() {
        local pod="$1"; shift
        [[ -z "$pod" ]] && { echo "Usage: kexec <pod> [shell]"; return 1; }
        kubectl exec -it "$pod" -- "${1:-/bin/sh}"
    }

    kwatch()   { kubectl get "$@" -w 2>&1 | kcolor; }
    kevents()  { kubectl get events --sort-by='.lastTimestamp' "$@" 2>&1 | kcolor; }
    krollout() { [[ -z "$1" ]] && { echo "Usage: krollout <resource>"; return 1; }; kubectl rollout status "$@" --watch; }

    ktop() {
        if [[ "$1" == "node"* ]]; then
            kubectl top nodes "${@:2}" 2>&1 | kcolor
        else
            kubectl top pods "$@" 2>&1 | kcolor
        fi
    }

    # ─── Safe apply (PROD dry-run suggestion) ──────────────────────

    ka() {
        local ctx ns
        ctx=$(kubectl config current-context 2>/dev/null)
        ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
        : "${ns:=default}"

        if _is_prod_context "$ctx" "$ns"; then
            echo -e "\033[48;5;208m\033[1;38;5;232m PROD APPLY \033[0m \033[1;38;5;208mkubectl apply $*\033[0m"
            echo -e "\033[38;5;250m  Context: $ctx | Namespace: $ns\033[0m"
            read -rp "  Run --dry-run=server first? [Y/n] " ans
            if [[ ! "$ans" =~ ^[Nn]$ ]]; then
                echo -e "\033[38;5;250m  ── dry-run output ──\033[0m"
                kubectl apply --dry-run=server "$@" 2>&1 | kcolor
                echo ""
                read -rp "  Proceed with real apply? [y/N] " ans2
                [[ "$ans2" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }
            fi
        fi
        kubectl apply "$@"
    }

    kaf() { ka -f "$@"; }

    # ─── Safe delete (PROD confirmation) ────────────────────────────

    kd() {
        local ctx ns
        ctx=$(kubectl config current-context 2>/dev/null)
        ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
        : "${ns:=default}"

        if _is_prod_context "$ctx" "$ns"; then
            echo -e "\033[48;5;196m\033[1;38;5;255m PROD DELETE \033[0m \033[1;38;5;196mkubectl delete $*\033[0m"
            echo -e "\033[38;5;250m  Context: $ctx | Namespace: $ns\033[0m"
            read -rp "  Type 'yes' to confirm: " ans
            [[ "$ans" == "yes" ]] || { echo "Cancelled."; return 1; }
        fi
        kubectl delete "$@"
    }

    # ─── Safe edit (PROD confirmation) ─────────────────────────────

    ke() {
        local ctx ns
        ctx=$(kubectl config current-context 2>/dev/null)
        ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
        : "${ns:=default}"

        if _is_prod_context "$ctx" "$ns"; then
            echo -e "\033[48;5;220m\033[1;38;5;232m PROD EDIT \033[0m \033[1;38;5;220mkubectl edit $*\033[0m"
            echo -e "\033[38;5;250m  Context: $ctx | Namespace: $ns\033[0m"
            read -rp "  Type 'yes' to confirm: " ans
            [[ "$ans" == "yes" ]] || { echo "Cancelled."; return 1; }
        fi
        kubectl edit "$@"
    }

    kdns() {
        [[ -z "$1" ]] && { echo "Usage: kdns <namespace>"; return 1; }
        echo -e "\033[1;38;5;196m Deleting namespace: $1\033[0m"
        echo -e "\033[38;5;250m  This will destroy ALL resources in the namespace.\033[0m"
        read -rp "  Type the namespace name to confirm: " ans
        [[ "$ans" == "$1" ]] || { echo "Cancelled."; return 1; }
        kubectl delete namespace "$1"
    }

    kdrain() {
        [[ -z "$1" ]] && { echo "Usage: kdrain <node>"; return 1; }
        echo -e "\033[1;38;5;220m Draining node: $1\033[0m"
        echo -e "\033[38;5;250m  This will evict all pods (except DaemonSets).\033[0m"
        read -rp "  Continue? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }
        kubectl drain "$1" --ignore-daemonsets --delete-emptydir-data --force
    }

    kcordon() {
        [[ -z "$1" ]] && { echo "Usage: kcordon <node>"; return 1; }
        echo -e "\033[1;38;5;220m Cordoning node: $1\033[0m"
        kubectl cordon "$1"
    }

    kuncordon() {
        [[ -z "$1" ]] && { echo "Usage: kuncordon <node>"; return 1; }
        echo -e "\033[1;38;5;82m Uncordoning node: $1\033[0m"
        kubectl uncordon "$1"
    }

    # ====================== COMPLETION ======================
    if command -v kubectl >/dev/null 2>&1; then
        source <(kubectl completion bash)
        complete -o default -F __start_kubectl k

        __kubectl_alias() {
            local subcmd="$1"; shift
            local cur prev words cword split
            if declare -F _init_completion >/dev/null 2>&1; then
                _init_completion -n =: || return
            else
                __kubectl_init_completion -n =: || return
            fi
            words=("kubectl" "$subcmd" "${words[@]:1}")
            (( cword++ ))
            local out directive
            __kubectl_get_completion_results
            __kubectl_process_completion_results
        }

        _kg()  { __kubectl_alias get; }
        _ka()  { __kubectl_alias apply; }
        _kd()  { __kubectl_alias delete; }
        _ki()  { __kubectl_alias describe; }
        _ke()  { __kubectl_alias edit; }
        _kl()  { __kubectl_alias logs; }
        _kla() { __kubectl_alias logs; }

        complete -o default -F _kg  kg
        complete -o default -F _ka  ka
        complete -o default -F _kd  kd
        complete -o default -F _ki  ki
        complete -o default -F _ke  ke
        complete -o default -F _kl  kl
        complete -o default -F _kla kla

        _kns() {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W \
                "$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)" \
                -- "$cur") )
        }
        complete -F _kns kns
        complete -F _kns kdns

        _kctx() {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W \
                "$(kubectl config get-contexts -o name 2>/dev/null)" \
                -- "$cur") )
        }
        complete -F _kctx kctx
        complete -F _kctx cll

        _kexec_complete() {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            if (( COMP_CWORD == 1 )); then
                COMPREPLY=( $(compgen -W \
                    "$(kubectl get pods -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)" \
                    -- "$cur") )
            elif (( COMP_CWORD == 2 )); then
                COMPREPLY=( $(compgen -W "/bin/sh /bin/bash /bin/ash" -- "$cur") )
            fi
        }
        complete -F _kexec_complete kexec

        # Node completion for kdrain
        _kdrain_complete() {
            local cur="${COMP_WORDS[COMP_CWORD]}"
            COMPREPLY=( $(compgen -W \
                "$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)" \
                -- "$cur") )
        }
        complete -F _kdrain_complete kdrain
        complete -F _kdrain_complete kcordon
        complete -F _kdrain_complete kuncordon

        _ka()  { __kubectl_alias apply; }
        _kaf() { __kubectl_alias apply; }
        complete -o default -F _ka  ka
        complete -o default -F _kaf kaf
    fi

    # bash-completion package (for non-kubectl tools: systemctl, git, etc.)
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        . /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        . /etc/bash_completion
    fi

    # ====================== CRICTL HELPERS ======================
    # Find container ID by pod name and namespace
    cidsearch() {
        [[ -z "$1" || -z "$2" ]] && { echo "Usage: cidsearch <pod> <namespace>"; return 1; }
        crictl ps \
            --label io.kubernetes.pod.name="$1" \
            --label io.kubernetes.pod.namespace="$2" \
            -o json | jq -r '.containers[].id'
    }

    # Find host PID of a container by pod name and namespace
    cpidsearch() {
        [[ -z "$1" || -z "$2" ]] && { echo "Usage: cpidsearch <pod> <namespace>"; return 1; }
        crictl inspect "$(cidsearch "$1" "$2")" | jq .info.pid
    }

    # ====================== ETCD ======================
    unalias etcdctl etcdctlMembers etcdctlRevision 2>/dev/null

    if [[ -d /etc/kubernetes/pki/etcd ]]; then
        _ETCD_CERTS=(
            --cert=/etc/kubernetes/pki/etcd/peer.crt
            --key=/etc/kubernetes/pki/etcd/peer.key
            --cacert=/etc/kubernetes/pki/etcd/ca.crt
        )
    fi

    etcdctl() { command etcdctl "${_ETCD_CERTS[@]}" "$@"; }

    etcdctlMembers() {
        etcdctl member list -w json | jq -r '[.members[].clientURLs[]?] | join(",")'
    }

    etcdctlRevision() {
        etcdctl \
            --endpoints="$(etcdctlMembers)" \
            endpoint status \
            -w json | jq -r '.[].Status.header.revision'
    }

    # ====================== HISTORY PROTECTION ======================
    # Make history files append-only (survives accidental > redirect)
    # Silently skip if chattr not available or filesystem doesn't support it
    for _hf in "$HISTFILE" "${HOME}/.bash_eternal_history"; do
        [[ -f "$_hf" ]] || touch "$_hf" 2>/dev/null
        chattr +a "$_hf" 2>/dev/null
    done
    unset _hf

    # ====================== LOCAL OVERRIDES ======================
    # Source machine-specific customizations if present
    [[ -f ~/.bashrc.local ]] && . ~/.bashrc.local

    # ====================== MOTD + STATUS ======================
    MOTD_ENABLED=${MOTD_ENABLED:-1}
    MOTD_TIMEOUT=${MOTD_TIMEOUT:-5}

    _show_motd() {
        [[ "$MOTD_ENABLED" != "1" ]] && return

        local G='\033[1;38;5;82m' R='\033[1;38;5;196m' Y='\033[1;38;5;220m'
        local C='\033[1;38;5;81m' GR='\033[38;5;250m' DIM='\033[38;5;245m'
        local BLD='\033[1;97m' RST='\033[0m'
        local SEP="${DIM}$(printf '─%.0s' {1..70})${RST}"
        local _T="${MOTD_TIMEOUT}"

        # ── Parallel data collection ──────────────────────────────────────
        local _tmpd _old_monitor
        _tmpd=$(mktemp -d "/tmp/.motd.XXXXXX")
        trap 'rm -rf "$_tmpd" 2>/dev/null' RETURN

        # Disable job control notifications during background collection
        _old_monitor=$(set +o | grep monitor)
        set +m 2>/dev/null

        if command -v kubectl >/dev/null 2>&1; then
            timeout "${_T}"s kubectl get nodes --no-headers > "$_tmpd/nodes" 2>/dev/null &
            timeout "${_T}"s kubectl get nodes -o wide > "$_tmpd/nodes_wide" 2>/dev/null &
            timeout "${_T}"s kubectl get pods -A --no-headers > "$_tmpd/pods_all" 2>/dev/null &
            timeout "${_T}"s kubectl get pods -A > "$_tmpd/pods_all_hdr" 2>/dev/null &
            timeout "${_T}"s kubectl get pods -n kube-system > "$_tmpd/kube_sys" 2>/dev/null &
            timeout "${_T}"s kubectl version -o json > "$_tmpd/version" 2>/dev/null &
            timeout "${_T}"s kubectl top pods -A --no-headers --sort-by=cpu > "$_tmpd/top" 2>/dev/null &
            timeout "${_T}"s kubectl top pods -A --sort-by=cpu > "$_tmpd/top_hdr" 2>/dev/null &
        fi

        if [[ -d /etc/kubernetes/pki/etcd ]] && command -v etcdctl >/dev/null 2>&1; then
            local _ep
            _ep=$(timeout "${_T}"s bash -c "$(declare -p _ETCD_CERTS 2>/dev/null); $(declare -f etcdctl etcdctlMembers); etcdctlMembers" 2>/dev/null)
            if [[ -n "$_ep" ]]; then
                timeout "${_T}"s bash -c "$(declare -p _ETCD_CERTS 2>/dev/null); $(declare -f etcdctl); etcdctl --endpoints=\"$_ep\" member list -w table" > "$_tmpd/etcd" 2>/dev/null &
            fi
        fi

        if command -v cilium >/dev/null 2>&1; then
            timeout "${_T}"s cilium status --brief > "$_tmpd/cilium" 2>/dev/null &
        fi

        wait
        eval "$_old_monitor" 2>/dev/null

        # ── 1. NODE ───────────────────────────────────────────────────────
        local _host _kern _up _cpus _mem_t _mem_a _load _ip _dns
        _host=$(hostname -f 2>/dev/null || hostname)
        _kern=$(uname -r)
        _up=$(uptime -p 2>/dev/null | sed 's/^up //' || uptime | sed 's/.*up //;s/,.*load.*//')
        _cpus=$(nproc 2>/dev/null || echo "?")
        _mem_t=$(awk '/MemTotal/{printf "%.0fG", $2/1048576}' /proc/meminfo 2>/dev/null)
        _mem_a=$(awk '/MemAvailable/{printf "%.1fG", $2/1048576}' /proc/meminfo 2>/dev/null)
        _load=$(awk '{printf "%s %s %s", $1, $2, $3}' /proc/loadavg 2>/dev/null)
        _ip=$(ip -4 route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
        _dns=$(awk '/^nameserver/{a=a sep $2; sep=","} END{print a}' /etc/resolv.conf 2>/dev/null)

        echo -e "${SEP}"
        echo -e "${BLD}  NODE${RST}   ${C}${_host}${RST}  ${DIM}│${RST}  ${GR}${_kern}${RST}"
        echo -e "         ${GR}${_cpus} CPU${RST}  ${DIM}│${RST}  ${GR}${_mem_t} RAM${RST} ${C}(${_mem_a} free)${RST}  ${DIM}│${RST}  ${GR}load ${_load}${RST}  ${DIM}│${RST}  ${GR}up ${_up}${RST}"
        echo -e "         ${GR}ip ${C}${_ip}${RST}  ${DIM}│${RST}  ${GR}dns ${_dns}${RST}"

        # ── 2. DISK + SYS ────────────────────────────────────────────────
        local _disk_line="" _df_out _usage _pct
        for _mp in / /var/lib/containerd /var/lib/kubelet; do
            [[ -d "$_mp" ]] || continue
            _df_out=$(command df -h "$_mp" 2>/dev/null | tail -1)
            _usage=$(echo "$_df_out" | awk '{print $5}')
            _pct=${_usage%%%}; _pct=${_pct:-0}
            local _dc="${G}"
            (( _pct >= 80 )) && _dc="${R}"
            (( _pct >= 60 && _pct < 80 )) && _dc="${Y}"
            _disk_line+="${GR}${_mp} ${_dc}${_usage}${RST}$(echo "$_df_out" | awk '{printf " (%s/%s)", $3, $2}')${RST}  "
        done

        local _ct_cur=0 _ct_max=0 _ct_pct=0 _ct_str=""
        if [[ -f /proc/sys/net/netfilter/nf_conntrack_count ]]; then
            _ct_cur=$(< /proc/sys/net/netfilter/nf_conntrack_count)
            _ct_max=$(< /proc/sys/net/netfilter/nf_conntrack_max)
            (( _ct_max > 0 )) && _ct_pct=$(( _ct_cur * 100 / _ct_max ))
            local _ctc="${G}"
            (( _ct_pct >= 80 )) && _ctc="${R}"
            (( _ct_pct >= 50 && _ct_pct < 80 )) && _ctc="${Y}"
            _ct_str="${GR}conntrack ${_ctc}${_ct_cur}/${_ct_max} (${_ct_pct}%)${RST}"
        fi

        local _sd_fail _sd_cnt _sd_str="${G}systemd: all ok${RST}"
        _sd_fail=$(systemctl --failed --no-legend 2>/dev/null)
        _sd_cnt=0
        [[ -n "$_sd_fail" ]] && _sd_cnt=$(echo "$_sd_fail" | wc -l)
        if (( _sd_cnt > 0 )); then
            _sd_str="${R}systemd: ${_sd_cnt} failed${RST}"
        fi

        local _cri_str=""
        if command -v crictl >/dev/null 2>&1; then
            local _cri_cnt
            _cri_cnt=$(crictl ps -q 2>/dev/null | wc -l)
            _cri_str="  ${DIM}│${RST}  ${GR}containers: ${C}${_cri_cnt}${RST}"
        fi

        echo -e "${BLD}  DISK${RST}   ${_disk_line}"
        echo -e "${BLD}  SYS${RST}    ${_ct_str}  ${DIM}│${RST}  ${_sd_str}${_cri_str}"

        if (( _sd_cnt > 0 )); then
            echo "$_sd_fail" | while IFS= read -r _line; do
                [[ -n "$_line" ]] && echo -e "         ${R}  ${_line}${RST}"
            done
        fi

        echo -e "${SEP}"

        # ── 3. K8S + PODS ─────────────────────────────────────────────────
        if command -v kubectl >/dev/null 2>&1; then
            local _ctx _ns _ver _nodes_t _nodes_r _nodes_nr

            _ctx=$(kubectl config current-context 2>/dev/null || echo "none")
            _ns=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null)
            : "${_ns:=default}"
            _ver=$(jq -r '.serverVersion.gitVersion // empty' "$_tmpd/version" 2>/dev/null)

            _nodes_t=$(wc -l < "$_tmpd/nodes" 2>/dev/null) || _nodes_t=0
            _nodes_r=$(grep -c ' Ready' "$_tmpd/nodes" 2>/dev/null) || _nodes_r=0
            : "${_nodes_t:=0}" "${_nodes_r:=0}"
            _nodes_nr=$(( _nodes_t - _nodes_r ))

            local _nc="${G}"
            (( _nodes_nr > 0 )) && _nc="${R}"

            echo -e "${BLD}  K8S${RST}    ${C}${_ctx##*@}${RST}  ${DIM}│${RST}  ${GR}ns=${RST}${Y}${_ns}${RST}  ${DIM}│${RST}  ${GR}${_ver}${RST}  ${DIM}│${RST}  ${_nc}${_nodes_r}/${_nodes_t} nodes ready${RST}"

            # ── 4. Pods summary ──
            if [[ -s "$_tmpd/pods_all" ]]; then
                local _p_total _p_run _p_pend _p_fail _p_compl _p_other
                _p_total=$(wc -l < "$_tmpd/pods_all") || _p_total=0
                _p_run=$(grep -c 'Running' "$_tmpd/pods_all") || _p_run=0
                _p_pend=$(grep -c 'Pending' "$_tmpd/pods_all") || _p_pend=0
                _p_fail=$(grep -cE 'CrashLoopBackOff|Error|Failed|ImagePullBackOff|OOMKilled|Evicted' "$_tmpd/pods_all") || _p_fail=0
                _p_compl=$(grep -cE 'Completed|Succeeded' "$_tmpd/pods_all") || _p_compl=0
                : "${_p_total:=0}" "${_p_run:=0}" "${_p_pend:=0}" "${_p_fail:=0}" "${_p_compl:=0}"
                _p_other=$(( _p_total - _p_run - _p_pend - _p_fail - _p_compl ))

                local _ps="${G}${_p_run} running${RST}"
                (( _p_pend > 0 ))  && _ps+="  ${Y}${_p_pend} pending${RST}"
                (( _p_fail > 0 ))  && _ps+="  ${R}${_p_fail} failing${RST}"
                (( _p_compl > 0 )) && _ps+="  ${DIM}${_p_compl} completed${RST}"
                (( _p_other > 0 )) && _ps+="  ${DIM}${_p_other} other${RST}"

                echo -e "${BLD}  PODS${RST}   ${_ps}  ${DIM}(${_p_total} total)${RST}"
            fi

            # ── 7. Certs ──
            if [[ -d /etc/kubernetes/pki ]]; then
                local _cert_warn="" _cert_ok=0 _cert_total=0 _now_epoch
                _now_epoch=$(date +%s)
                local _30d=$(( _now_epoch + 30 * 86400 ))

                while IFS= read -r _crt; do
                    (( _cert_total++ ))
                    local _exp_str _exp_epoch _cn _days_left
                    _exp_str=$(openssl x509 -enddate -noout -in "$_crt" 2>/dev/null | cut -d= -f2)
                    [[ -z "$_exp_str" ]] && continue
                    _exp_epoch=$(date -d "$_exp_str" +%s 2>/dev/null) || continue
                    _cn=$(openssl x509 -subject -noout -in "$_crt" 2>/dev/null | sed 's/.*CN *= *//')
                    _days_left=$(( (_exp_epoch - _now_epoch) / 86400 ))

                    if (( _exp_epoch < _now_epoch )); then
                        _cert_warn+="         ${R}  EXPIRED  ${_cn}  ($(basename "$_crt"))${RST}\n"
                    elif (( _exp_epoch < _30d )); then
                        _cert_warn+="         ${Y}  ${_days_left}d left  ${_cn}  ($(basename "$_crt"))${RST}\n"
                    else
                        (( _cert_ok++ ))
                    fi
                done < <(find /etc/kubernetes/pki -maxdepth 2 -name '*.crt' -type f 2>/dev/null)

                if [[ -n "$_cert_warn" ]]; then
                    echo -e "${BLD}  CERTS${RST}  ${R}attention required${RST}"
                    echo -ne "$_cert_warn"
                elif (( _cert_total > 0 )); then
                    echo -e "${BLD}  CERTS${RST}  ${G}all ${_cert_total} valid > 30d${RST}"
                fi
            fi

            # ── 8. Cilium ──
            if [[ -s "$_tmpd/cilium" ]]; then
                local _cil
                _cil=$(head -1 "$_tmpd/cilium")
                if echo "$_cil" | grep -qi 'ok\|ready'; then
                    echo -e "${BLD}  CNI${RST}    ${G}${_cil}${RST}"
                else
                    echo -e "${BLD}  CNI${RST}    ${Y}${_cil}${RST}"
                fi
            fi

            echo -e "${SEP}"

            # ── Nodes table ──
            if [[ -s "$_tmpd/nodes_wide" ]]; then
                echo -e "${BLD}  NODES${RST}"
                sed 's/^/    /' "$_tmpd/nodes_wide" | kcolor
                echo -e "${SEP}"
            fi

            # ── 5. Problem pods table ──
            if [[ -s "$_tmpd/pods_all_hdr" ]]; then
                local _prob_body
                _prob_body=$(tail -n +2 "$_tmpd/pods_all_hdr" | grep -vE 'Running|Completed|Succeeded' || true)
                if [[ -n "$_prob_body" ]]; then
                    local _prob_cnt
                    _prob_cnt=$(echo "$_prob_body" | wc -l)
                    echo -e "${BLD}  PROBLEMS${RST} ${R}(${_prob_cnt})${RST}"
                    { head -1 "$_tmpd/pods_all_hdr"; echo "$_prob_body" | head -20; } | \
                        sed 's/^/    /' | kcolor
                    (( _prob_cnt > 20 )) && echo -e "    ${DIM}... and $((_prob_cnt - 20)) more${RST}"
                    echo -e "${SEP}"
                fi
            fi

            # ── 6. Top 5 CPU table ──
            if [[ -s "$_tmpd/top_hdr" ]] && ! grep -qi 'error\|not available' "$_tmpd/top_hdr" 2>/dev/null; then
                echo -e "${BLD}  TOP CPU${RST}"
                head -6 "$_tmpd/top_hdr" | sed 's/^/    /' | kcolor
                echo -e "${SEP}"
            fi

            # ── 10. etcd members table ──
            if [[ -s "$_tmpd/etcd" ]]; then
                echo -e "${BLD}  ETCD${RST}"
                sed 's/^/    /' "$_tmpd/etcd"
                echo -e "${SEP}"
            elif [[ -d /etc/kubernetes/pki/etcd ]]; then
                echo -e "${BLD}  ETCD${RST}   ${Y}no endpoints / could not reach${RST}"
                echo -e "${SEP}"
            fi

            # ── 11. kube-system pods table ──
            if [[ -s "$_tmpd/kube_sys" ]]; then
                echo -e "${BLD}  KUBE-SYSTEM${RST}"
                sed 's/^/    /' "$_tmpd/kube_sys" | kcolor
                echo -e "${SEP}"
            fi
        fi

        # ── 12. Quick reference ──
        echo -e "  ${DIM}kg ki kl ka kd ke${RST} ${GR}get describe logs apply delete edit${RST}  ${DIM}│${RST}  ${DIM}kns kctx cll${RST} ${GR}ns/ctx${RST}  ${DIM}│${RST}  ${DIM}kexec ktop kdrain kevents${RST}"
    }
    _show_motd
    unset -f _show_motd
{{- end }}
