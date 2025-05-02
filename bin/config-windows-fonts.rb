require 'win32/registry'
require 'fileutils'
require 'open-uri'

# === 设置系统注册表开启字体平滑（模拟 macOS 灰度抗锯齿风格） ===
def enable_font_smoothing
  puts '[*] 开启 Windows 字体平滑...'

  Win32::Registry::HKEY_CURRENT_USER.open('Control Panel\\Desktop', Win32::Registry::KEY_WRITE) do |reg|
    reg['FontSmoothing'] = '2'               # 开启字体平滑
    reg['FontSmoothingType'] = 2             # 2 = ClearType（次像素抗锯齿）
    reg['FontSmoothingGamma'] = 1800         # Gamma 值调整，越高字体越黑
    reg['FontSmoothingOrientation'] = 1      # RGB 子像素方向
  end

  puts '[+] 字体平滑设置完成。'
end

# === 静默安装 MacType（字体渲染替代工具） ===
def install_mactype
  puts '[*] 下载并安装 MacType...'

  url = 'https://github.com/snowie2000/mactype/releases/download/v1.2025.4.11/MacTypeInstaller_2025.4.11.exe'
  exe_file = 'MacTypeSetup.exe'

  # 下载
  File.open(exe_file, 'wb') do |saved_file|
    URI.open(url, 'rb') do |read_file|
      saved_file.write(read_file.read)
    end
  end

  puts '[*] 开始静默安装 MacType...'
  system("start /wait #{exe_file} /VERYSILENT /NORESTART")

  puts '[+] MacType 安装完成。'
end

# === 配置 MacType 加载模式 ===
def configure_mactype(scheme: 'Default')
  puts '[*] 配置 MacType 加载模式为注册表...'

  begin
    key_path = 'Software\\MacType'
    Win32::Registry::HKEY_CURRENT_USER.create(key_path, Win32::Registry::KEY_WRITE) do |reg|
      reg['InstallMode'] = 'registry'    # 加载方式：注册表
      reg['UserSetting'] = 1
      reg['UserScheme'] = scheme         # 方案名称
    end
    puts "[+] MacType 注册表配置完成（方案：#{scheme}）"
  rescue StandardError => e
    puts "[!] 配置 MacType 失败：#{e.message}"
  end
end

# === 重启资源管理器使设置生效 ===
def restart_explorer
  puts '[*] 重启资源管理器以应用字体设置...'
  system('taskkill /f /im explorer.exe')
  sleep(1)
  system('start explorer.exe')
end

# === 主执行流程 ===
def main
  puts '=== Windows 字体美化工具（模拟 macOS 效果） ==='

  enable_font_smoothing

  puts "\n是否安装并配置 MacType 工具？(y/n)"
  print '> '
  if gets.strip.downcase == 'y'
    install_mactype
    configure_mactype
  end

  puts "\n是否重启资源管理器以应用字体效果？(y/n)"
  print '> '
  restart_explorer if gets.strip.downcase == 'y'

  puts "\n[*] 字体美化操作完成。请重启电脑以完全生效（尤其是 MacType 部分）。"
end

main
