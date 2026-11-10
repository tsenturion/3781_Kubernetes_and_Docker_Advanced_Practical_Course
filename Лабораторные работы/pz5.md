# Лабораторная работа № 5

**Модуль 5. Дополнительные инструменты Kubernetes**

## Цель лабораторной работы

Освоить расширение возможностей Kubernetes с помощью Custom Resource Definitions (CRD) и операторов, научиться устанавливать и управлять приложениями через Helm, применять Istio Service Mesh для управления сетевым трафиком и организовывать процессы непрерывной интеграции и доставки приложений (CI/CD).

**Ожидаемый результат:** работающий кластер K3s с установленным оператором cert-manager, пользовательским ресурсом CRD, собственным Helm-чартом веб-приложения, настроенной маршрутизацией трафика через Istio и CI/CD-процессом, обеспечивающим автоматическую проверку конфигурации и управляемое развёртывание приложения.

## Задание

### Шаг 1. Подготовка Kubernetes-кластера

1. Проверьте состояние K3s и доступность Kubernetes API.
2. Убедитесь, что узел кластера находится в состоянии `Ready`.
3. Определите версии Kubernetes и K3s.
4. Проверьте наличие утилиты Helm.
5. Проверьте доступность команды `kubectl` для работы с кластером.
6. Создайте пространство имён `lab5`.
7. Создайте каталог проекта `k8s-lab5`.
8. Проверьте доступные ресурсы процессора и оперативной памяти.
9. Убедитесь, что в кластере достаточно ресурсов для работы оператора cert-manager, Istio и учебного приложения.

Установку дополнительных компонентов выполняйте на выделенном учебном кластере. Для Istio рекомендуется иметь не менее 4 виртуальных процессоров и 8 ГБ оперативной памяти, хотя фактические требования зависят от конфигурации.

### Шаг 2. Изучение и создание Custom Resource Definition

1. Получите список CRD, уже зарегистрированных в Kubernetes.
2. Выберите один существующий CRD и изучите его структуру.
3. Создайте файл `crd-labtask.yaml`.
4. Опишите собственный тип Kubernetes-ресурса с названием `LabTask`.
5. Используйте группу API `training.example.com` и версию `v1`.
6. Добавьте в схему объекта обязательное поле `spec.message`.
7. Зарегистрируйте CRD в Kubernetes.
8. Проверьте появление нового типа ресурса.
9. Создайте файл `labtask.yaml` с экземпляром собственного ресурса.
10. Создайте объект `LabTask` с именем `demo-task`.
11. Получите информацию о созданном объекте через `kubectl`.
12. Измените значение поля `spec.message`.
13. Повторно примените манифест и проверьте обновление данных.
14. Объясните, почему создание CRD само по себе не приводит к выполнению действий, описанных в пользовательском ресурсе.

В отчёте отразите различие между CRD, Custom Resource и Kubernetes-контроллером.

### Шаг 3. Установка Kubernetes-оператора

1. Изучите назначение оператора cert-manager.
2. Добавьте или настройте официальный источник Helm-чарта cert-manager.
3. Установите cert-manager в отдельное пространство имён.
4. Убедитесь, что Deployment оператора и его вспомогательные компоненты работают.
5. Получите список CRD, установленных вместе с cert-manager.
6. Найдите пользовательские типы `Certificate` и `Issuer`.
7. Изучите структуру CRD `certificates.cert-manager.io`.
8. Проверьте доступность пользовательских ресурсов через `kubectl`.
9. Определите, какие контроллеры отвечают за обработку этих ресурсов.

Не устанавливайте cert-manager повторно, если он уже используется другими приложениями в кластере. В таком случае используйте существующую установку для изучения его работы.

### Шаг 4. Проверка работы оператора

1. Создайте файл `certificate.yaml`.
2. Опишите объект `Issuer` с именем `lab5-selfsigned`.
3. Выберите тип `SelfSigned` для выпуска учебного сертификата.
4. Создайте объект `Certificate` с именем `lab5-certificate`.
5. Укажите имя результирующего Secret `lab5-tls`.
6. Примените YAML-манифесты.
7. Дождитесь появления сертификата в состоянии `Ready`.
8. Проверьте, что cert-manager автоматически создал Secret.
9. Изучите события объекта Certificate.
10. Удалите созданный Secret, не удаляя Certificate.
11. Наблюдайте за действиями оператора.
12. Убедитесь, что оператор восстановил необходимый Secret.
13. Объясните, как реализуется механизм Reconciliation Loop.

Используйте самоподписанный сертификат исключительно для лабораторного эксперимента. Он не предназначен для подтверждения подлинности публичных веб-сайтов.

### Шаг 5. Создание собственного Helm-чарта

1. Создайте каталог `charts/lab5-web`.
2. Создайте файл `Chart.yaml`.
3. Укажите название чарта `lab5-web` и его версию.
4. Создайте файл `values.yaml` для параметров приложения.
5. Настройте использование контейнерного образа `hashicorp/http-echo`.
6. Укажите две реплики стабильной версии приложения.
7. Добавьте возможность включения и отключения Canary Deployment.
8. Создайте каталог `templates`.
9. Добавьте шаблон стабильного Deployment.
10. Добавьте шаблон Canary Deployment.
11. Добавьте шаблон Service.
12. Используйте Helm-переменные вместо жёстко заданных параметров.
13. Проверьте синтаксис Helm-чарта.
14. Сгенерируйте Kubernetes-манифесты без установки приложения.
15. Убедитесь, что шаблоны корректно преобразуются в объекты Kubernetes.

### Шаг 6. Установка приложения через Helm

1. Установите созданный Helm-чарт в пространство имён `lab5`.
2. Используйте имя релиза `lab5-web`.
3. Проверьте состояние Helm-релиза.
4. Получите список созданных Deployment и Service.
5. Убедитесь, что запущены две реплики приложения.
6. Создайте диагностический Pod для HTTP-запросов.
7. Проверьте доступность приложения внутри кластера.
8. Получите параметры установленного Helm-релиза.
9. Измените количество стабильных реплик на три через Helm.
10. Выполните обновление релиза.
11. Проверьте создание дополнительного Pod.
12. Изучите историю релиза.
13. Выполните откат к первоначальной конфигурации.
14. Убедитесь, что количество реплик восстановлено.

Определите различие между Helm-релизом, Helm-чартом и Kubernetes Deployment.

### Шаг 7. Установка Istio Service Mesh

1. Изучите назначение Istio и архитектуру Service Mesh.
2. Установите совместимую с кластером версию `istioctl`.
3. Установите Istio с учебным профилем `demo` без внешних Gateway.
4. Проверьте создание пространства имён `istio-system`.
5. Убедитесь, что управляющая плоскость Istio работает.
6. Найдите Deployment `istiod`.
7. Включите автоматическую Sidecar Injection в пространстве имён `lab5`.
8. Пересоздайте Pod учебного приложения.
9. Проверьте появление контейнера `istio-proxy`.
10. Убедитесь, что все компоненты приложения находятся в состоянии `Ready`.
11. Проверьте состояние прокси через `istioctl proxy-status`.
12. Выполните HTTP-запрос к приложению из диагностического Pod, включённого в Service Mesh.

В K3s по умолчанию может работать Traefik. Для этой лабораторной работы отдельный Istio Ingress Gateway не требуется, поскольку сетевое взаимодействие проверяется внутри кластера.

### Шаг 8. Настройка маршрутизации через Istio

1. Измените Helm-конфигурацию и включите Canary Deployment.
2. Убедитесь, что в кластере работают версии `v1` и `v2`.
3. Создайте файл `istio-routing.yaml`.
4. Опишите объект `DestinationRule`.
5. Добавьте два subset: `v1` и `v2`.
6. Настройте соответствие subset меткам Pod.
7. Создайте объект `VirtualService`.
8. Настройте отправку 90% трафика к версии `v1` и 10% к версии `v2`.
9. Примените манифест.
10. Выполните 100 HTTP-запросов из диагностического Pod внутри Service Mesh.
11. Подсчитайте ответы от каждой версии приложения.
12. Измените распределение трафика на 50% и 50%.
13. Повторите эксперимент.
14. Сравните полученные результаты.
15. Объясните преимущество процентной маршрутизации Istio по сравнению с распределением запросов только за счёт количества реплик.

Точное процентное распределение в небольшой выборке не гарантируется. Для корректного эксперимента каждый HTTP-запрос должен проходить через прокси Istio.

### Шаг 9. Создание CI-процесса

1. Создайте Git-репозиторий для лабораторного проекта.
2. Добавьте исходные файлы Helm-чарта.
3. Создайте каталог `.github/workflows`.
4. Добавьте файл `ci.yaml`.
5. Настройте автоматический запуск проверки при `push` и `pull_request`.
6. Добавьте этап получения исходного кода.
7. Добавьте установку Helm.
8. Настройте проверку Helm-чарта через `helm lint`.
9. Добавьте генерацию Kubernetes-манифестов через `helm template`.
10. Проверьте генерацию конфигурации со включённым Canary Deployment.
11. Отправьте изменения в удалённый репозиторий GitHub.
12. Убедитесь, что workflow запустился автоматически.
13. Проверьте результат выполнения всех этапов.
14. Намеренно создайте ошибку в одном из шаблонов.
15. Повторно отправьте изменения.
16. Убедитесь, что CI-проверка обнаружила ошибку.
17. Исправьте шаблон и добейтесь успешного выполнения workflow.

Для этого этапа достаточно проверки Kubernetes-конфигурации. Сборка контейнерного образа не требуется, поскольку приложение использует готовый образ из реестра.

### Шаг 10. Организация CD-процесса

1. Создайте каталог `scripts`.
2. Создайте файл `deploy.sh`.
3. Добавьте проверку Helm-чарта перед развёртыванием.
4. Настройте установку или обновление приложения через `helm upgrade --install`.
5. Добавьте ожидание готовности Deployment.
6. Запретите продолжение выполнения скрипта при ошибке.
7. Выполните скрипт на учебном Linux-сервере.
8. Проверьте успешное развёртывание приложения.
9. Измените значение параметра `replicaCount` в `values.yaml`.
10. Отправьте изменение в GitHub.
11. Дождитесь успешного завершения CI-проверки.
12. Запустите CD-скрипт после проверки.
13. Убедитесь, что изменения применились к Kubernetes.
14. Зафиксируйте историю обновлений Helm-релиза.
15. Выполните откат при необходимости.

В этой лабораторной работе CI запускается автоматически через GitHub Actions, а CD выполняется вручную после успешной проверки. Это контролируемая модель доставки с ручным подтверждением, а не полностью автоматическое развёртывание.

### Шаг 11. Итоговая проверка и подготовка проекта

1. Проверьте работу установленного оператора.
2. Убедитесь, что пользовательский CRD зарегистрирован.
3. Проверьте состояние сертификата и соответствующего Secret.
4. Убедитесь, что Helm-релиз находится в состоянии `deployed`.
5. Проверьте состояние стабильного и Canary Deployment.
6. Проверьте наличие прокси Istio в Pod приложения.
7. Выполните HTTP-запросы и подтвердите маршрутизацию трафика.
8. Проверьте успешный запуск CI workflow.
9. Убедитесь, что CD-скрипт корректно разворачивает приложение.
10. Проверьте историю Helm-релиза.
11. Подготовьте скриншоты и результаты основных экспериментов.
12. Сформируйте итоговый отчёт.

---

## Подсказки по ключевым частям

### Проверка кластера и настройка доступа

```bash
sudo systemctl status k3s
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A

helm version
sudo k3s kubectl create namespace lab5
mkdir -p ~/k8s-lab5
cd ~/k8s-lab5
```

Для использования Helm и Istio требуется настроить обычный `kubectl` на подключение к K3s.

На выделенном учебном сервере можно подготовить административную конфигурацию:

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown "$(id -u):$(id -g)" ~/.kube/config
chmod 600 ~/.kube/config

kubectl get nodes
```

Этот kubeconfig предоставляет административный доступ к кластеру. Не копируйте его в проект, не отправляйте в GitHub и не используйте на общем компьютере без соответствующих мер защиты.

В дальнейшем для Helm, Istio и примеров используется команда `kubectl` без `sudo`.

### Создание собственного CRD

Создайте файл `crd-labtask.yaml`:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: labtasks.training.example.com
spec:
  group: training.example.com
  scope: Namespaced
  names:
    plural: labtasks
    singular: labtask
    kind: LabTask
    shortNames:
      - ltask
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required:
                - message
              properties:
                message:
                  type: string
```

Примените:

```bash
kubectl apply -f crd-labtask.yaml
kubectl get crd labtasks.training.example.com
```

Создайте `labtask.yaml`:

```yaml
apiVersion: training.example.com/v1
kind: LabTask
metadata:
  name: demo-task
  namespace: lab5
spec:
  message: "First custom Kubernetes resource"
```

Проверьте:

```bash
kubectl apply -f labtask.yaml
kubectl -n lab5 get labtasks
kubectl -n lab5 describe labtask demo-task
```

Созданный CRD расширяет API Kubernetes новым типом ресурса. Однако без собственного контроллера этот ресурс не будет автоматически создавать Pod, Deployment или другие объекты.

### Установка оператора cert-manager

Используйте официальный OCI Helm-чарт. Перед установкой проверьте совместимость версии cert-manager с вашим Kubernetes.

Пример установки:

```bash
helm install cert-manager \
  oci://quay.io/jetstack/charts/cert-manager \
  --version v1.20.4 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --wait
```

Проверьте:

```bash
kubectl get pods -n cert-manager
kubectl get crd | grep cert-manager
kubectl get deployments -n cert-manager
```

Для общей установки cert-manager необходимо согласование с администратором: оператор и его CRD являются кластерными компонентами.

### Создание сертификата через оператора

Создайте файл `certificate.yaml`:

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: lab5-selfsigned
  namespace: lab5
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: lab5-certificate
  namespace: lab5
spec:
  secretName: lab5-tls
  duration: 2160h
  renewBefore: 360h
  dnsNames:
    - lab5-web.lab5.svc.cluster.local
  issuerRef:
    name: lab5-selfsigned
    kind: Issuer
```

Примените:

```bash
kubectl apply -f certificate.yaml

kubectl -n lab5 wait \
  --for=condition=Ready certificate/lab5-certificate \
  --timeout=180s

kubectl -n lab5 get certificate
kubectl -n lab5 get secret lab5-tls
```

Проверьте механизм автоматического восстановления:

```bash
kubectl -n lab5 delete secret lab5-tls
kubectl -n lab5 get secret -w
```

Наблюдайте за повторным появлением `lab5-tls`. При необходимости проверьте события Certificate и журналы cert-manager. Повторное создание Secret может потребовать времени.

### Создание Helm-чарта

Создайте структуру:

```bash
mkdir -p charts/lab5-web/templates
```

Файл `charts/lab5-web/Chart.yaml`:

```yaml
apiVersion: v2
name: lab5-web
description: Kubernetes laboratory application
type: application
version: 0.1.0
appVersion: "1.0"
```

Файл `charts/lab5-web/values.yaml`:

```yaml
image:
  repository: hashicorp/http-echo
  tag: "1.0.0"

replicaCount: 2

stable:
  message: "VERSION-1"

canary:
  enabled: false
  replicaCount: 1
  message: "VERSION-2"
```

Создайте `charts/lab5-web/templates/deployment-stable.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab5-web-stable
spec:
  replicas: { { .Values.replicaCount } }
  selector:
    matchLabels:
      app: lab5-web
      version: v1
  template:
    metadata:
      labels:
        app: lab5-web
        version: v1
    spec:
      containers:
        - name: web
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          args:
            - "-listen=:5678"
            - "-text={{ .Values.stable.message }}"
          ports:
            - containerPort: 5678
```

Создайте `charts/lab5-web/templates/deployment-canary.yaml`:

```yaml
{{- if .Values.canary.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab5-web-canary
spec:
  replicas: {{ .Values.canary.replicaCount }}
  selector:
    matchLabels:
      app: lab5-web
      version: v2
  template:
    metadata:
      labels:
        app: lab5-web
        version: v2
    spec:
      containers:
        - name: web
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          args:
            - "-listen=:5678"
            - "-text={{ .Values.canary.message }}"
          ports:
            - containerPort: 5678
{{- end }}
```

Создайте `charts/lab5-web/templates/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lab5-web
spec:
  type: ClusterIP
  selector:
    app: lab5-web
  ports:
    - port: 5678
      targetPort: 5678
```

Проверьте чарт:

```bash
helm lint charts/lab5-web
helm template lab5-web charts/lab5-web -n lab5
```

### Установка и обновление Helm-релиза

```bash
helm upgrade --install lab5-web charts/lab5-web \
  -n lab5 --wait --timeout 5m

helm list -n lab5
kubectl -n lab5 get deployments,pods,services
```

Для изменения числа реплик:

```bash
helm upgrade lab5-web charts/lab5-web \
  -n lab5 --set replicaCount=3 --wait

helm history lab5-web -n lab5
```

Для отката к предыдущей ревизии:

```bash
helm rollback lab5-web 1 -n lab5 --wait
```

Номер ревизии необходимо предварительно проверить через `helm history`. Не предполагайте, что нужная ревизия всегда равна `1`.

### Установка Istio

Загрузите официальный дистрибутив Istio:

```bash
curl -L https://istio.io/downloadIstio | sh -
```

Перейдите в созданный каталог `istio-<версия>` и добавьте каталог `bin` в `PATH`:

```bash
export PATH="$PWD/bin:$PATH"
istioctl version --remote=false
```

Установите учебную конфигурацию без Gateway:

```bash
istioctl install \
  -f samples/bookinfo/demo-profile-no-gateways.yaml -y
```

Проверьте управляющую плоскость:

```bash
kubectl get pods -n istio-system
kubectl get deployments -n istio-system
```

Включите Sidecar Injection:

```bash
kubectl label namespace lab5 istio-injection=enabled \
  --overwrite

kubectl -n lab5 rollout restart deployment/lab5-web-stable
kubectl -n lab5 rollout status deployment/lab5-web-stable
```

Проверьте наличие Envoy:

```bash
kubectl -n lab5 get pods
istioctl proxy-status
```

В режиме Sidecar у работающего Pod приложения обычно будут два контейнера: основное приложение и `istio-proxy`.

### Создание диагностического клиента

Создайте Pod внутри пространства имён с включённой Sidecar Injection:

```bash
kubectl -n lab5 run lab5-client \
  --image=curlimages/curl:8.12.1 \
  --restart=Never \
  --command -- sleep 36000
```

Дождитесь состояния `Running` и готовности обоих контейнеров.

Проверьте:

```bash
kubectl -n lab5 get pod lab5-client
kubectl -n lab5 exec lab5-client -c lab5-client -- \
  curl -fsS http://lab5-web:5678
```

Ответ должен содержать `VERSION-1`.

### Включение Canary Deployment

```bash
helm upgrade lab5-web charts/lab5-web \
  -n lab5 --set canary.enabled=true --wait

kubectl -n lab5 get pods --show-labels
```

Убедитесь, что появились Pod версии `v2` с прокси Istio.

### Настройка VirtualService и DestinationRule

Создайте файл `istio-routing.yaml`:

```yaml
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: lab5-web
  namespace: lab5
spec:
  host: lab5-web
  subsets:
    - name: v1
      labels:
        version: v1
    - name: v2
      labels:
        version: v2
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: lab5-web
  namespace: lab5
spec:
  hosts:
    - lab5-web
  http:
    - route:
        - destination:
            host: lab5-web
            subset: v1
          weight: 90
        - destination:
            host: lab5-web
            subset: v2
          weight: 10
```

Примените:

```bash
kubectl apply -f istio-routing.yaml
istioctl analyze -n lab5
```

Проверьте 100 запросов:

```bash
kubectl -n lab5 exec lab5-client -c lab5-client -- sh -c '
i=0
while [ "$i" -lt 100 ]; do
  curl -fsS http://lab5-web:5678
  i=$((i+1))
done
' | sort | uniq -c
```

Измените `weight` на `50` для обеих версий, повторно примените манифест и выполните проверку.

Процентная маршрутизация Istio применяется к запросам, проходящим через прокси Service Mesh. Проверка только через `kubectl port-forward` не подтверждает корректность процентной маршрутизации.

### Настройка CI через GitHub Actions

Создайте файл `.github/workflows/ci.yaml`:

```yaml
name: Kubernetes CI

on:
  push:
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Helm
        uses: azure/setup-helm@v4.3.0
        with:
          version: v3.19.0

      - name: Helm lint
        run: helm lint charts/lab5-web

      - name: Render stable deployment
        run: |
          helm template lab5-web charts/lab5-web \
            --namespace lab5 > stable.yaml

      - name: Render canary deployment
        run: |
          helm template lab5-web charts/lab5-web \
            --namespace lab5 \
            --set canary.enabled=true > canary.yaml

      - name: Verify generated manifests
        run: |
          grep -q "lab5-web-stable" stable.yaml
          grep -q "lab5-web-canary" canary.yaml
```

При отправке изменений в GitHub будет автоматически запускаться проверка Helm-чарта и генерации манифестов.

Для проверки обнаружения ошибок удалите обязательную часть шаблона, нарушив его синтаксис, выполните `git push` и изучите результат workflow. Затем исправьте ошибку.

### Настройка управляемого CD

Создайте файл `scripts/deploy.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

helm lint charts/lab5-web

helm upgrade --install lab5-web charts/lab5-web \
  --namespace lab5 \
  --wait \
  --timeout 5m \
  "$@"

kubectl -n lab5 rollout status \
  deployment/lab5-web-stable \
  --timeout=180s

echo "Deployment completed successfully"
```

Предоставьте файлу права на выполнение:

```bash
chmod +x scripts/deploy.sh
```

Выполните установку или обновление:

```bash
./scripts/deploy.sh
```

Для включения Canary:

```bash
./scripts/deploy.sh --set canary.enabled=true
```

Скрипт выполняется на машине, имеющей настроенный доступ к Kubernetes. Не помещайте административный kubeconfig в GitHub-репозиторий или переменные workflow без необходимости.

Для полностью автоматического CD потребовалась бы отдельная настройка защищённого механизма доставки в кластер, например GitOps-контроллера или изолированного CI/CD-агента с ограниченными правами. В текущем задании развёртывание запускается вручную после проверки CI.

### Очистка учебных ресурсов

Перед отключением Canary Deployment восстановите маршрутизацию Istio на 100% к версии `v1`. Иначе VirtualService может продолжить направлять часть запросов к отсутствующим Pod.

Для удаления приложения:

```bash
helm uninstall lab5-web -n lab5
kubectl delete -f istio-routing.yaml --ignore-not-found
kubectl delete -f labtask.yaml --ignore-not-found
```

Удалять CRD, cert-manager или Istio следует только в случае, если они устанавливались специально для этой лабораторной работы и не используются другими приложениями.

---

## Что изменить, чтобы выполнить работу на Kubernetes (K8s) вместо K3s

K3s является дистрибутивом Kubernetes. CRD, операторы, Helm и Istio работают с теми же интерфейсами Kubernetes API. Основные изменения касаются подготовки кластера, настройки доступа и сетевой инфраструктуры.

### 1. Заменить проверку K3s

Вместо:

```bash
sudo systemctl status k3s
sudo k3s kubectl get nodes
```

используйте:

```bash
sudo systemctl status kubelet
kubectl get nodes
kubectl get pods -A
```

Команда проверки службы `kubelet` применима к узлам Kubernetes, на которых она управляется через systemd, например в кластерах `kubeadm`.

### 2. Изменить способ доступа

В K3s административный kubeconfig обычно расположен по пути:

```text
/etc/rancher/k3s/k3s.yaml
```

В кластере, развёрнутом через `kubeadm`, обычно используется:

```text
/etc/kubernetes/admin.conf
```

Настройте `kubectl` с помощью подходящего kubeconfig. В управляемых Kubernetes-сервисах используйте механизм доступа, предоставляемый соответствующей платформой.

### 3. Проверить совместимость оператора

Установка cert-manager через Helm выполняется аналогично.

Перед установкой проверьте совместимость версии cert-manager с версией Kubernetes. Если оператор уже установлен, повторно устанавливать его не требуется.

Объекты `Issuer` и `Certificate` используют одинаковый API.

### 4. Оставить Helm-чарт без изменений

Файлы `Chart.yaml`, `values.yaml` и шаблоны Deployment и Service менять не требуется.

Используйте те же команды:

```bash
helm lint charts/lab5-web
helm upgrade --install lab5-web charts/lab5-web -n lab5
```

### 5. Проверить поддержку Istio

Перед установкой Istio проверьте совместимость версии Kubernetes, сетевого плагина CNI и выбранной версии Istio.

Для выполнения лабораторной работы используйте конфигурацию Istio в режиме Sidecar. Если в кластере уже установлен Istio, используйте существующую управляющую плоскость и подходящий механизм включения Sidecar Injection.

### 6. Проверить внешнюю сетевую инфраструктуру

В K3s по умолчанию могут использоваться Traefik и ServiceLB. В стандартном Kubernetes-кластере аналогичные функции могут обеспечивать другие компоненты.

В этой лабораторной работе используется Service типа `ClusterIP`, поэтому внешний балансировщик не требуется.

Если вы хотите дополнительно открыть приложение из внешней сети, понадобится настроить соответствующий Gateway, Ingress или другой механизм публикации сервиса.

### 7. Оставить CI/CD-процесс без изменений

GitHub Actions выполняет проверку Helm-чарта без подключения к кластеру. Поэтому файл `.github/workflows/ci.yaml` не зависит от использования K3s или стандартного Kubernetes.

Для CD необходимо только настроить `kubectl` и Helm на подключение к целевому кластеру.

**Итог:** при переходе с K3s на обычный Kubernetes основные YAML-манифесты, Helm-чарт, Istio-маршрутизация и CI/CD-проверки сохраняются. Изменяются способ доступа к кластеру и настройки его инфраструктурных компонентов.

---

## Что проверить перед отправкой (чек-лист)

- [ ] Кластер K3s работает корректно.
- [ ] Создано пространство имён `lab5`.
- [ ] Создан и зарегистрирован собственный CRD `LabTask`.
- [ ] Создан и изменён пользовательский ресурс `demo-task`.
- [ ] Установлен и проверен оператор cert-manager.
- [ ] Созданы объекты Issuer и Certificate.
- [ ] Подтверждено автоматическое создание Secret оператором.
- [ ] Проверена реакция оператора на удаление Secret.
- [ ] Создан собственный Helm-чарт.
- [ ] Helm-чарт успешно проходит `helm lint`.
- [ ] Приложение установлено через Helm.
- [ ] Выполнены обновление и откат Helm-релиза.
- [ ] Установлен и проверен Istio.
- [ ] В Pod приложения присутствует прокси `istio-proxy`.
- [ ] Созданы DestinationRule и VirtualService.
- [ ] Настроено распределение трафика 90/10.
- [ ] Настроено распределение трафика 50/50.
- [ ] Выполнена серия HTTP-запросов с подсчётом ответов.
- [ ] Создан Git-репозиторий проекта.
- [ ] Настроен автоматический CI workflow.
- [ ] Продемонстрировано обнаружение ошибки в Helm-шаблоне.
- [ ] Создан и проверен CD-скрипт.
- [ ] Подготовлены результаты экспериментов и скриншоты.
- [ ] Все исходные файлы включены в архив проекта.

## Советы по улучшению работы

**Разделяйте CRD и контроллеры.** Custom Resource Definition описывает структуру нового объекта API, а контроллер реализует логику его обработки. При проектировании собственных операторов учитывайте необходимость повторяемой и безопасной обработки изменений состояния.

**Проверяйте совместимость операторов.** Перед установкой изучайте поддерживаемые версии Kubernetes, набор устанавливаемых CRD, права доступа и потребление ресурсов.

**Используйте версионирование Helm-чартов.** При изменении шаблонов и возможностей приложения обновляйте версию чарта. Для воспроизводимых установок фиксируйте версии зависимостей и контейнерных образов.

**Проверяйте результат Helm Template.** Успешное выполнение `helm lint` не гарантирует корректной работы приложения в Kubernetes. Проверяйте итоговые YAML-манифесты и состояние объектов после развёртывания.

**Учитывайте ограничения Service Mesh.** Istio добавляет дополнительные компоненты, увеличивающие потребление ресурсов и сложность инфраструктуры. Используйте его возможности там, где требуется управление трафиком, политиками взаимодействия или наблюдаемостью между сервисами.

**Разделяйте CI и CD.** CI должен обнаруживать ошибки до развёртывания. CD должен обеспечивать управляемую доставку проверенных изменений с возможностью остановки и отката.

**Защищайте доступ CI/CD к кластеру.** Не передавайте административные kubeconfig и долгоживущие токены в репозитории. Для автоматического развёртывания применяйте минимальные права доступа и защищённые механизмы аутентификации.

## Вопросы для рефлексии

1. **Чем отличается пользовательский ресурс Kubernetes от оператора?** Почему после регистрации CRD можно создавать новые типы объектов, но для автоматического управления приложением необходим контроллер?

2. **Какие задачи решает Helm и чем он отличается от обычного применения YAML-манифестов через `kubectl apply`?** В каких ситуациях использование Helm существенно упрощает сопровождение приложения?

3. **Какие преимущества предоставляет Istio Service Mesh при развёртывании нескольких версий приложения?** Почему процентное распределение трафика через VirtualService является более управляемым механизмом, чем изменение количества реплик Deployment?

4. **Почему в процессе CI/CD важно выполнять проверки до развёртывания приложения?** Какие ошибки можно обнаружить с помощью `helm lint` и `helm template`, а какие проблемы становятся видны только после запуска приложения в Kubernetes?

5. **Представьте, что новая версия приложения успешно прошла CI, но после развёртывания через Helm начала возвращать HTTP-ошибки.** Как использовать Helm, Istio и средства Kubernetes для определения причины неисправности, ограничения трафика на проблемную версию и восстановления стабильной работы?

## Результат выполнения лабораторной работы

Подготовьте архив `k8s-lab5.zip`, содержащий исходные файлы проекта:

- `crd-labtask.yaml` — описание пользовательского типа ресурса.
- `labtask.yaml` — экземпляр пользовательского ресурса.
- `certificate.yaml` — конфигурация Issuer и Certificate.
- `charts/lab5-web/` — собственный Helm-чарт со всеми шаблонами.
- `istio-routing.yaml` — маршрутизация трафика через Istio.
- `.github/workflows/ci.yaml` — автоматическая проверка конфигурации.
- `scripts/deploy.sh` — скрипт развёртывания приложения.
- `README.md` — инструкция по установке и запуску проекта.
- `reflection.md` — ответы на пять вопросов для рефлексии.
- `screenshots/` — скриншоты основных этапов работы.

В `README.md` укажите версии Kubernetes, Helm, cert-manager и Istio, результаты установки оператора, результаты проверки CRD, историю Helm-релиза, статистику распределения запросов между версиями приложения и результаты выполнения CI/CD.

Дополнительно приложите ссылку на GitHub-репозиторий с успешно выполненным CI workflow. Репозиторий не должен содержать kubeconfig, токены доступа или другие конфиденциальные данные.

**Критерий успешного выполнения:** преподаватель должен иметь возможность воспроизвести создание пользовательского CRD, проверить работу cert-manager, установить приложение из собственного Helm-чарта, настроить распределение трафика через Istio и убедиться, что CI-процесс автоматически проверяет конфигурацию, а CD-скрипт обеспечивает управляемое развёртывание приложения в Kubernetes.
