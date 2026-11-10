[CmdletBinding()]
param(
    [ValidateSet('Check', 'Install')]
    [string]$Stage = 'Check'
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$remote = @'
set -euo pipefail

stage='__STAGE__'
version='v1.37.2+k3s1'
config=/etc/rancher/k3s/config.yaml
unit=k3s.service

fail() {
  printf '%s\n' "$*"
  exit 1
}

test "$(id -u)" = 0 || fail 'Требуется вход от root.'
test "$(hostname -s)" = master1 || fail 'SSH должен вести на узел master1.'
test "$(ps -p 1 -o comm=)" = systemd || fail 'На узле требуется systemd.'
test "$(stat -fc %T /sys/fs/cgroup)" = cgroup2fs || fail 'На узле требуется cgroup v2.'
test -z "$(swapon --noheadings --show=NAME)" || fail 'На узле активен swap. Проверьте настройки узла перед установкой.'
command -v curl | grep -q . || fail 'На узле требуется curl.'

addresses=$(ip -o -4 address show dev enp0s8 scope global | awk '{sub("/.*","",$4); print $4}')
[[ "$addresses" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
  fail 'На enp0s8 нужен ровно один глобальный IPv4-адрес.'
node_ip=$addresses

expected_config=$(cat <<YAML
# Учебный стенд курса, тема 2.3
node-name: master1
node-ip: "$node_ip"
flannel-iface: enp0s8
flannel-backend: host-gw
write-kubeconfig-mode: "0600"
secrets-encryption: true
YAML
)

if [[ -L "$config" || -e "$config.d" || -L "$config.d" ]]; then
  fail 'Найдена дополнительная или перенаправленная конфигурация k3s. Проверьте её перед установкой.'
fi

if [[ -e "$config" ]]; then
  test -f "$config" || fail 'Путь конфигурации k3s должен быть обычным файлом.'
  test "$(cat "$config")" = "$expected_config" ||
    fail 'Существующая конфигурация отличается от конфигурации учебного стенда.'
else
  if command -v k3s | grep -q . ||
    [[ -e /var/lib/rancher/k3s || -e /etc/systemd/system/k3s.service || -e /etc/systemd/system/k3s-agent.service ]]; then
    fail 'Обнаружена существующая установка k3s. Проверьте её отдельно.'
  fi

  occupied=$(ss -H -ltn '( sport = :6443 or sport = :10250 or sport = :80 or sport = :443 )')
  test -z "$occupied" || fail "Один из портов стенда уже занят: $occupied"
fi

if command -v k3s | grep -q .; then
  installed=$(k3s --version | awk 'NR == 1 {print $3}')
  test "$installed" = "$version" || fail "Установлена другая версия k3s: $installed"
fi

printf 'master1 | enp0s8=%s | CPU=%s | RAM=%s МиБ | свободно=%s | k3s=%s\n' \
  "$node_ip" "$(nproc)" "$(awk '/^MemTotal:/ {print int($2/1024)}' /proc/meminfo)" \
  "$(df -h --output=avail / | awk 'NR == 2 {print $1}')" "$version"

if [[ "$stage" = Check ]]; then
  exit 0
fi

if [[ ! -e "$config" ]]; then
  install -d -m 0755 /etc/rancher/k3s
  (umask 077; printf '%s\n' "$expected_config" | dd of="$config" conv=excl status=none)
fi

if ! command -v k3s | grep -q . || [[ ! -f /etc/systemd/system/k3s.service ]]; then
  installer=$(mktemp /tmp/k3s-course-install.XXXXXX)
  trap 'rm -f -- "$installer"' EXIT
  curl -fsSL --retry 2 --connect-timeout 10 https://get.k3s.io -o "$installer"
  INSTALL_K3S_VERSION="$version" INSTALL_K3S_SKIP_START=true sh "$installer" server
fi

if ! timeout 300s systemctl enable --now "$unit"; then
  systemctl status --no-pager --lines=0 "$unit" || true
  fail 'Служба k3s не подтвердила запуск за отведённое время. Проверьте журнал службы.'
fi

k3s --version | sed -n '1p'
systemctl is-active "$unit"
'@

$remote.Replace('__STAGE__', $Stage) |
    ssh -o BatchMode=yes -o ConnectTimeout=8 master1-root 'tr -d ''\015'' | bash -s'

if ($LASTEXITCODE -ne 0) {
    throw "Этап $Stage завершился ошибкой. См. вывод SSH."
}
