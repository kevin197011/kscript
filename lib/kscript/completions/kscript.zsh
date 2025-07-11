#compdef kscript
_kscript() {
  local -a commands
  commands=(
    'apnic_ip:kscript command'
    'aws_s3:kscript command'
    'cursor_rules:kscript command'
    'elastic_cert_finger:kscript command'
    'ffmpeg_install:kscript command'
    'file_rename:kscript command'
    'ip_lookup:kscript command'
    'jenkins_manage:kscript command'
    'kibana_manage:kscript command'
    'lvm_manage:kscript command'
    'mac_optimize:kscript command'
    'mac_status:kscript command'
    'port_scan:kscript command'
    'project_scan:kscript command'
    'shell_helper:kscript command'
    'usd_rate:kscript command'
    'vcs_cleaner:kscript command'
    'wg_acl:kscript command'
    'wg_pass:kscript command'
  )
  _describe 'command' commands
}
compdef _kscript kscript
