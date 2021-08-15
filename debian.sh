#! /bin/bash

#Created Time:2021/08/16
#Script Description:Debian部署

# 更换源
apt update

# 备份apt/sources.list
echo "apt源文件备份"
cp /etc/apt/sources.list /etc/apt/sources.list.back
echo "备份文件在/etc/apt/sources.list.back"

# 修改apt/sources.list
cat <<EOM>/etc/apt/sources.list
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb http://mirrors.aliyun.com/debian-security buster/updates main
deb-src http://mirrors.aliyun.com/debian-security buster/updates main
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
EOM

echo "源文件替换为aliyun！开始系统更新"

# 系统更新
apt update && apt upgrade -y
echo "系统跟新完成"

# 修改sshd_config

# 备份sshd_config
echo "备份sshd_config"
cp  /etc/ssh/sshd_config /etc/ssh/sshd_config.back
echo "备份文件在/etc/ssh/sshd_config.back"

# 设置ssh端口号
read -t 10 -p '请输入需要修改的端口号：' Port

# 修改 sshd_config 内容
sed -i "/Port /c\Port $Port\nProtocol 2" /etc/ssh/sshd_config
sed -i "/AddressFamily /c\AddressFamily inet" /etc/ssh/sshd_config
sed -i "/HostKey \/etc\/ssh\/ssh_host_rsa_key/c\HostKey \/etc\/ssh\/ssh_host_rsa_key" /etc/ssh/sshd_config
sed -i "/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/c\HostKey \/etc\/ssh\/ssh_host_ecdsa_key" /etc/ssh/sshd_config
sed -i "/HostKey \/etc\/ssh\/ssh_host_ed25519_key/c\HostKey \/etc\/ssh\/ssh_host_ed25519_key" /etc/ssh/sshd_config
sed -i "/SyslogFacility /c\SyslogFacility AUTHPRIV" /etc/ssh/sshd_config
sed -i "/LogLevel /c\LogLevel INFO" /etc/ssh/sshd_config
sed -i "/LoginGraceTime /c\LoginGraceTime 30s" /etc/ssh/sshd_config
sed -i "/PermitRootLogin /c\PermitRootLogin no" /etc/ssh/sshd_config
sed -i "/StrictModes /c\StrictModes yes" /etc/ssh/sshd_config
sed -i "/MaxAuthTries /c\MaxAuthTries 6" /etc/ssh/sshd_config
sed -i "/MaxSessions /c\MaxSessions 10" /etc/ssh/sshd_config
sed -i "/PubkeyAuthentication /c\PubkeyAuthentication yes" /etc/ssh/sshd_config
sed -i "/AuthorizedKeysFile/c\AuthorizedKeysFile     .ssh\/authorized_keys .ssh\/authorized_keys2" /etc/ssh/sshd_config
sed -i "/HostbasedAuthentication /c\HostbasedAuthentication no" /etc/ssh/sshd_config
sed -i "/IgnoreUserKnownHosts /c\IgnoreUserKnownHosts no" /etc/ssh/sshd_config
sed -i "/IgnoreRhosts /c\IgnoreRhosts yes" /etc/ssh/sshd_config
sed -i "/PasswordAuthentication /c\PasswordAuthentication no" /etc/ssh/sshd_config
sed -i "/PermitEmptyPasswords /c\PermitEmptyPasswords no" /etc/ssh/sshd_config
sed -i "/GSSAPICleanupCredentials /c\GSSAPICleanupCredentials no" /etc/ssh/sshd_config
sed -i "/UsePAM /c\UsePAM yes" /etc/ssh/sshd_config
sed -i "A/X11Forwarding /c\X11Forwarding no" /etc/ssh/sshd_config
sed -i "/PrintMotd /c\PrintMotd no" /etc/ssh/sshd_config
sed -i "/PrintLastLog /c\PrintLastLog no" /etc/ssh/sshd_config
sed -i "/TCPKeepAlive /c\TCPKeepAlive yes" /etc/ssh/sshd_config
sed -i "/ClientAliveInterval /c\ClientAliveInterval 600" /etc/ssh/sshd_config
sed -i "/ClientAliveCountMax /c\ClientAliveCountMax 2" /etc/ssh/sshd_config
sed -i "/UseDNS /c\UseDNS yes" /etc/ssh/sshd_config
sed -i "/AcceptEnv /c\AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES\nAcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT\nAcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE\nAcceptEnv XMODIFIERS" /etc/ssh/sshd_config
cat /etc/ssh/sshd_config
echo "sshd_config文件修改完成"


# su加固 
sed -i "A/auth       required   pam_wheel.so/c\auth       required   pam_wheel.so" /etc/pam.d/su
sed -i "/SU_WHEEL_ONLY/c\SU_WHEEL_ONLY yes" /etc/login.defs
read -t 60 -p "创建新用户，输入用户名" username
useradd -m $username
passwd $username
addgroup wheel
usermod -aG wheel $username

# sudo 安装
apt install sudo
# Sudo 设置
# 备份 sudoers 文件
cp /etc/sudoers /etc/sudoers.back
echo "备份文件在/etc/sudoers.back"

# 输入允许sudo权限的账户或者用户组
read -t 60 -p "请输入允许sudo的用户：（如需添加用户组则 '%user'）" username

# 设置允许sudo用户登录，切免密码访问
sed -i "/%sudo/c\\$username	ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
echo "以设定仅允许 $username 用户访问，且免密码登录"

# 密码策略
# 备份login.defs
cp /etc/login.defs /etc/login.defs.back
echo "备份文件在/etc/login.defs.back"
# 最多多少天不修改密码
sed -i "/PASS_MAX_DAYS /c\PASS_MAX_DAYS 90" /etc/login.defs
# 修改密码最短天数
sed -i "/PASS_MIN_DAYS /c\PASS_MIN_DAYS 0" /etc/login.defs
# 密码最短长度
sed -i "/PASS_MIN_LEN /c\PASS_MIN_LEN 8" /etc/login.defs
# 密码失效前多少天通知用户
sed -i "/PASS_WARN_AGE /c\PASS_WARN_AGE 10" /etc/login.defs
echo "已设置好密码策略......"

# 当密码输入错误达到2次，就锁定用户6000秒，如果root用户输入密码错误达到3次，锁定6000秒
sed -i "/# PAM /a\auth required pam_tally2.so deny=2 unlock_time=6000 even_deny_root root_unlock_time6000" /etc/pam.d/sshd
