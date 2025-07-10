# kscript bash completion
# Auto-generated command completion for kscript CLI

_kscript_completions() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Main command list as array
    local opts=(
        version help list apnic cleaner es_fingerprint ffmpeg ip jenkins kibana lvm optimize portscan projscan rename sh syscheck top usd wg_acl wg_pass
    )

    if [[ ${COMP_CWORD} == 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts[*]}" -- "${cur}") )
        return 0
    fi
}

complete -F _kscript_completions kscript
