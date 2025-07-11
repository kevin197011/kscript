# kscript bash completion
# Auto-generated command completion for kscript CLI

_kscript_completions() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Main command list as array
    local opts=(
        apnic_ip aws_s3 cursor_rules elastic_cert_finger ffmpeg_install file_rename ip_lookup jenkins_manage kibana_manage lvm_manage mac_optimize mac_status port_scan project_scan shell_helper usd_rate vcs_cleaner wg_acl wg_pass
    )

    if [[ ${COMP_CWORD} == 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts[*]}" -- "${cur}") )
        return 0
    fi
}

complete -F _kscript_completions kscript
