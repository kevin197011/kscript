#compdef kscript
_kscript() {
  local -a commands
  commands=(
    'version:kscript command'
    'help:kscript command'
    'list:kscript command'
    'apnic:kscript command'
    'cleaner:kscript command'
    'es_fingerprint:kscript command'
    'ffmpeg:kscript command'
    'ip:kscript command'
    'jenkins:kscript command'
    'kibana:kscript command'
    'lvm:kscript command'
    'optimize:kscript command'
    'portscan:kscript command'
    'projscan:kscript command'
    'rename:kscript command'
    'sh:kscript command'
    'syscheck:kscript command'
    'top:kscript command'
    'usd:kscript command'
    'wg_acl:kscript command'
    'wg_pass:kscript command'
  )
  _describe 'command' commands
}
compdef _kscript kscript