[CmdletBinding()]
param(
    [ValidateSet('Check', 'Install')]
    [string]$Stage = 'Check'
)

$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$remote = @'
set -euo pipefail

fail() {
  printf '%s\n' "$*"
  exit 1
}

stage='__STAGE__'
version=1.32.0
root=/root/k3s-lesson-5.4
ctl="$root/istio-$version/bin/istioctl"
release_url="https://github.com/istio/istio/releases/download/$version/istio-$version-linux-amd64.tar.gz"

test "$(hostname -s)" = master1 || fail 'SSH должен вести на узел master1.'
test "$(id -u)" = 0 || fail 'Требуется вход от root.'
test "$(uname -m)" = x86_64 || fail 'Для этого выпуска нужен узел x86_64.'
command -v curl | grep -q . || fail 'На узле требуется curl.'
command -v tar | grep -q . || fail 'На узле требуется tar.'

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
test "$(k3s kubectl get --raw=/readyz --request-timeout=10s)" = ok || fail 'API k3s не подтвердил готовность.'
k3s kubectl wait --for=condition=Ready --timeout=90s node/master1

control_plane=$(k3s kubectl get deployments -A -l app=istiod --request-timeout=10s \
  -o 'jsonpath={range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{"\n"}{end}')
if [[ -n "$control_plane" ]]; then
  test "$control_plane" = istio-system/istiod || fail 'Найдена другая установка Istio. Сверьте её конфигурацию с уроком.'
  pilot=$(k3s kubectl -n istio-system get deployment istiod --request-timeout=10s \
    -o 'jsonpath={.spec.template.spec.containers[?(@.name=="discovery")].image}')
  [[ "$pilot" = *":$version" ]] || fail "Учебный блок рассчитан на Istio $version. Образ найденного istiod: $pilot"
fi

if [[ "$stage" = Check ]]; then
  curl -fsSIL --connect-timeout 10 --max-time 20 -o /dev/null "$release_url"
  registry_status=$(curl -sS --connect-timeout 10 --max-time 20 -o /dev/null \
    -w '%{http_code}' https://registry-1.docker.io/v2/)
  case "$registry_status" in
    200|401) ;;
    *) fail "Docker Hub вернул HTTP $registry_status." ;;
  esac
  printf '%s\n' 'Проверка master1 пройдена. API k3s, архив Istio и Docker Hub доступны.'
  exit 0
fi

install -d -m 700 "$root"
if [[ ! -x "$ctl" ]]; then
  archive="$root/istio-$version-linux-amd64.tar.gz"
  curl -fL --connect-timeout 15 --max-time 300 --retry 2 "$release_url" -o "$archive"
  tar -xzf "$archive" -C "$root" "istio-$version/bin/istioctl"
  rm -f -- "$archive"
fi

if [[ -z "$control_plane" ]]; then
  "$ctl" install --set profile=minimal --set values.global.platform=k3s \
    --set hub=docker.io/istio --set tag="$version" --skip-confirmation
fi
k3s kubectl -n istio-system rollout status deployment/istiod --timeout=300s

images=$(k3s crictl images)
for image in "docker.io/istio/proxyv2:$version" docker.io/library/busybox:1.37.0; do
  if ! awk -v image="$image" '($1 ":" $2) == image { found = 1 } END { exit !found }' <<< "$images"; then
    k3s crictl pull "$image"
  fi
done

printf '%s\n' 'Istio готов к уроку 5.4.'
'@

$remote.Replace('__STAGE__', $Stage) |
    ssh -o BatchMode=yes -o ConnectTimeout=8 master1-root 'tr -d ''\015'' | bash -s'

if ($LASTEXITCODE -ne 0) {
    throw "Подготовка Istio на master1 завершилась ошибкой на этапе $Stage. См. вывод SSH."
}
