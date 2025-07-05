# kscript

```
______                     _____        _____
___  /________________________(_)_________  /_
__  //_/_  ___/  ___/_  ___/_  /___  __ \\  __/
_  ,<  _(__  )/ /__ _  /   _  / __  /_/ / /_
/_/|_| /____/ \\___/ /_/    /_/  _  .___/\\__/
                                /_/
```

[![Gem Version](https://img.shields.io/gem/v/kscript?style=flat-square)](https://rubygems.org/gems/kscript)
[![CI Status](https://github.com/kevin197011/kscript/actions/workflows/gem-push.yml/badge.svg?branch=main)](https://github.com/kevin197011/kscript/actions/workflows/gem-push.yml)

> Ruby CLI 工具集，专为系统运维、开发自动化、网络与项目管理场景设计。支持插件化、极致美化输出、自动补全、结构化日志、CI/CD 自动发布等现代特性。

---

## ✨ 特性亮点
- **统一 CLI 框架**：所有命令一键调用，美化输出
- **插件化架构**：业务命令即插件，易扩展、易维护
- **极致美化**：ASCII banner、彩色分组、对齐、分隔线，极客体验
- **人性化/结构化日志双模式**：`--log`/`--log-level` 切换，支持 JSON/终端友好输出
- **自动补全**：zsh/bash 补全脚本自动部署，命令一键补全
- **参数健壮**：所有插件兼容多余参数，支持全局参数过滤
- **CI/CD 自动发布**：GitHub Actions 自动构建并推送 RubyGem
- **多平台支持**：macOS、Linux、Windows（部分工具）

---

## 🚀 安装

```bash
gem install kscript
```

或源码安装：

```bash
git clone https://github.com/kevin197011/kscript.git
cd kscript
gem build kscript.gemspec
gem install ./kscript-*.gem
```

---

## 🛠️ 快速上手

### 查看所有命令
```bash
kscript list
```

### 查看主命令帮助
```bash
kscript help
```

### 查看版本
```bash
kscript version
```

### 执行插件命令
```bash
kscript <command> [args...]
# 例如
kscript apnic CN
kscript portscan 192.168.1.1
kscript sh 'ls -l'
kscript projscan ~/projects
```

### 结构化日志模式
```bash
kscript apnic CN --log
kscript portscan 192.168.1.1 --log-level=debug
```

---

## 🧩 插件与命令一览

> 运行 `kscript list` 可分组美化展示所有插件命令

- **network**
  - `apnic`：获取国家 IPv4 段
  - `portscan`：端口扫描
  - `ip`：IP 工具
  - `wg_acl`：WireGuard 防火墙 ACL
  - `wg_pass`：WireGuard 密码工具
- **project**
  - `projscan`：扫描目录下所有 git 项目
  - `cleaner`：源码多版本清理
  - `rename`：批量重命名文件
- **system/macos**
  - `syscheck`：macOS 系统健康检查
  - `top`：macOS 资源占用排行
  - `optimize`：macOS 性能优化
  - `sh`：命令行速查/cheatsheet
- **media**
  - `ffmpeg`：FFmpeg 安装与检测
- **elastic**
  - `es_fingerprint`：Elasticsearch 证书指纹
  - `kibana`：Kibana 空间/索引/用户/角色自动化
- **ci**
  - `jenkins`：Jenkins Job 导入导出
- **其它**
  - `usd`：美元汇率工具
  - `lvm`：LVM 卷管理
  - `windows_font_enhancer`：Windows 字体增强

---

## ⚡ Shell 自动补全

- **首次运行自动为 zsh/bash 部署补全脚本**，无需手动操作
- 补全脚本路径：
  - zsh: `~/.zsh/completions/_kscript`
  - bash: `~/.bash_completion.d/kscript`
- 手动生成：
  ```bash
  kscript completion zsh > ~/.zsh/completions/_kscript
  kscript completion bash > ~/.bash_completion.d/kscript
  ```

---

## ⚙️ 全局配置

在 `~/.kscriptrc` (YAML) 配置全局参数：

```yaml
log_level: debug
```

---

## 🧑‍💻 插件开发规范
- 插件文件统一放在 `lib/kscript/plugins/kk_xxx_utils.rb`
- 类名如 `KkApnicUtils`，自动注册为 `apnic` 命令
- 支持 `self.description`、`self.usage`、`self.arguments`、`self.group`、`self.author`
- 输出统一用 `logger.kinfo`/`logger.kerror`，支持结构化日志
- 兼容多余参数，避免 ArgumentError

---

## 🚚 CI/CD 自动发布

- `.github/workflows/gem-push.yml`：main 分支和 PR 自动构建、tag push 自动发布到 RubyGems
- 需在 GitHub secrets 配置 `RUBYGEMS_API_KEY`
- [CI 状态与历史](https://github.com/kevin197011/kscript/actions/workflows/gem-push.yml)

---

## 📄 许可证

MIT License. 详见 [LICENSE](LICENSE)。

---

## 🤝 贡献

1. Fork & PR
2. 遵循输出与插件开发规范
3. 保持文档与代码同步

---

如需更多示例、插件开发指导或遇到问题，欢迎提 issue 或 PR！

