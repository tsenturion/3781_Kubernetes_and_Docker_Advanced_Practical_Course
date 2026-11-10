# Лабораторная работа № 3

**Модуль 3. Расширенные темы Kubernetes**

## Цель лабораторной работы

Освоить расширенные возможности Kubernetes на базе K3s: настройку сетевого взаимодействия и Service Discovery, организацию постоянного хранения данных с использованием PersistentVolume и PersistentVolumeClaim, управление конфигурациями через ConfigMap и конфиденциальными параметрами через Secret. Научиться выполнять Rolling Update и Canary Deployment, проверять работоспособность новых версий приложений, откатывать изменения, анализировать метрики и журналы контейнеров.

**Ожидаемый результат:** в Kubernetes развёрнуто веб-приложение с двумя версиями, реализовано тестирование Canary Deployment, выполнены Rolling Update и откат, настроены постоянное хранилище и внешняя конфигурация, проверены сетевое взаимодействие, мониторинг и журналирование.

## Задание

### Шаг 1. Подготовка Kubernetes-кластера

1. Откройте терминал Linux и проверьте работоспособность ранее установленного K3s.
2. Убедитесь, что управляющий узел находится в состоянии `Ready`.
3. Получите список системных Pod и проверьте их состояние.
4. Найдите компоненты CoreDNS, Metrics Server и Local Path Provisioner.
5. Определите версии Kubernetes и K3s.
6. Создайте новое пространство имён `lab3`.
7. Создайте каталог проекта `k8s-lab3`.
8. Убедитесь, что в пространстве имён `lab3` отсутствуют объекты предыдущих лабораторных работ.

Если отдельные системные компоненты отсутствуют, проверьте конфигурацию кластера. В стандартной установке K3s CoreDNS, Metrics Server и Local Path Provisioner обычно устанавливаются автоматически.

### Шаг 2. Настройка сетевого взаимодействия и Service Discovery

1. Создайте YAML-манифест `configmaps.yaml`, содержащий две ConfigMap с разными версиями HTML-страницы.
2. Создайте Deployment `lab3-web-stable`, использующий первую версию страницы.
3. Установите количество реплик равным трём.
4. Создайте Service с именем `lab3-web` и типом `ClusterIP`.
5. Настройте Service для обращения к Pod по метке `app: lab3-web`.
6. Проверьте, что Service обнаруживает все три Pod.
7. Создайте временный диагностический Pod `dns-check` на основе BusyBox.
8. Проверьте DNS-разрешение имени `lab3-web.lab3.svc.cluster.local`.
9. Выполните HTTP-запрос к приложению из диагностического Pod.
10. Проверьте возможность обращения к приложению по короткому имени `lab3-web`.
11. Определите IP-адрес Service и IP-адреса отдельных Pod.
12. Объясните различие между ClusterIP и IP-адресом Pod.

Зафиксируйте результаты DNS-запросов и HTTP-проверок в отчёте.

### Шаг 3. Создание Persistent Storage

1. Получите список доступных StorageClass в Kubernetes.
2. Найдите StorageClass `local-path`.
3. Создайте YAML-файл `pvc.yaml`.
4. Опишите PersistentVolumeClaim с именем `lab3-data`, запрашивающий `1Gi` дискового пространства.
5. Укажите режим доступа `ReadWriteOnce`.
6. Создайте Pod `lab3-storage`, использующий созданный PVC.
7. Подключите том к каталогу `/data` внутри контейнера.
8. Дождитесь перехода PVC в состояние `Bound`.
9. Создайте в каталоге `/data` текстовый файл `test.txt`.
10. Запишите в файл произвольное сообщение с датой выполнения работы.
11. Удалите Pod `lab3-storage`, не удаляя PVC.
12. Создайте Pod повторно из того же манифеста.
13. Убедитесь, что созданный ранее файл сохранился.
14. Получите информацию о PersistentVolume, связанном с PVC.

Определите, где физически располагаются данные тома в K3s и почему удаление Pod не привело к удалению файла.

**Важно:** Local Path Provisioner использует локальное хранилище узла. Такое хранилище подходит для учебных задач, но не обеспечивает автоматического сохранения доступности данных при отказе самого узла.

### Шаг 4. Настройка ConfigMap

1. Изучите созданные объекты ConfigMap.
2. Убедитесь, что первая ConfigMap содержит HTML-страницу с текстом `VERSION 1`.
3. Убедитесь, что вторая ConfigMap содержит страницу с текстом `VERSION 2`.
4. Проверьте подключение ConfigMap к контейнерам через том.
5. Выполните HTTP-запрос к работающему приложению и убедитесь, что отображается первая версия.
6. Изучите способ подключения отдельных файлов ConfigMap с помощью `subPath`.
7. Определите, какие изменения конфигурации требуют пересоздания Pod.
8. Зафиксируйте различия между хранением конфигурации в Docker-образе и отдельном объекте ConfigMap.

Не изменяйте основную версию приложения до выполнения задания с Canary Deployment.

### Шаг 5. Создание и использование Secret

1. Создайте объект Secret с именем `lab3-secret`.
2. Добавьте в него учебный параметр `token`.
3. Настройте Pod `lab3-storage` для получения параметра из Secret через переменную окружения `LAB_TOKEN`.
4. Пересоздайте Pod, сохранив PVC.
5. Проверьте наличие переменной окружения внутри контейнера, не выводя её значение.
6. Получите список Secret в пространстве имён `lab3`.
7. Изучите метаданные созданного Secret.
8. Сравните назначение ConfigMap и Secret.
9. Объясните, почему конфиденциальные параметры не следует хранить непосредственно в YAML-манифестах Deployment.

Для лабораторной работы используйте только учебный токен, не имеющий доступа к реальным системам.

### Шаг 6. Реализация Canary Deployment

1. Убедитесь, что Deployment `lab3-web-stable` содержит три работающие реплики.
2. Создайте файл `deploy-canary.yaml`.
3. Опишите отдельный Deployment `lab3-web-canary`.
4. Укажите одну реплику приложения.
5. Подключите ConfigMap со второй версией HTML-страницы.
6. Добавьте метки `app: lab3-web` и `track: canary`.
7. Убедитесь, что существующий Service использует селектор `app: lab3-web` без ограничения по `track`.
8. Примените манифест Canary Deployment.
9. Проверьте, что теперь Service обнаруживает четыре Pod.
10. Выполните серию из 20 HTTP-запросов к Service.
11. Зафиксируйте количество ответов с `VERSION 1` и `VERSION 2`.
12. Повторите эксперимент и сравните результаты.

При равномерном распределении соединений можно ожидать приблизительно 75% обращений к стабильной версии и 25% к Canary, но точное соотношение не гарантируется. Обычный Kubernetes Service не обеспечивает процентное управление трафиком: выбор конечной точки зависит от сетевой реализации и соединений.

### Шаг 7. Выполнение Rolling Update

1. Откройте файл `deploy-stable.yaml`.
2. Найдите настройки стратегии обновления Deployment.
3. Убедитесь, что используется стратегия `RollingUpdate`.
4. Установите `maxSurge: 1` и `maxUnavailable: 0`.
5. Измените ConfigMap, используемую стабильным Deployment, с `lab3-page-v1` на `lab3-page-v2`.
6. Примените обновлённый YAML-манифест.
7. Наблюдайте за последовательным созданием новых Pod и удалением старых.
8. Проверьте успешное завершение обновления.
9. Убедитесь, что все три Pod стабильного Deployment используют вторую версию приложения.
10. Проверьте доступность Service.
11. Получите историю обновлений Deployment.
12. Зафиксируйте состояние ReplicaSet до и после обновления.

Объясните, почему изменение шаблона Pod в Deployment запускает Rolling Update.

### Шаг 8. Откат приложения

1. Убедитесь, что обновление стабильно работающего Deployment успешно завершено.
2. Получите историю ревизий.
3. Выполните откат Deployment к предыдущей ревизии.
4. Наблюдайте за изменением состояния Pod.
5. Дождитесь завершения отката.
6. Проверьте, что стабильные Pod снова используют ConfigMap `lab3-page-v1`.
7. Выполните HTTP-запросы непосредственно к стабильному Deployment.
8. Убедитесь, что возвращена первая версия HTML-страницы.
9. Проверьте состояние Service и ReplicaSet.
10. Приведите `deploy-stable.yaml` в соответствие с восстановленной конфигурацией.

Canary Deployment во время отката оставьте работающим. Это позволит отдельно наблюдать первую и вторую версии приложения.

### Шаг 9. Мониторинг ресурсов Kubernetes

1. Получите информацию об использовании CPU и оперативной памяти узлом.
2. Получите сведения о потреблении ресурсов всеми Pod в `lab3`.
3. Сравните потребление ресурсов стабильного Deployment и Canary Deployment.
4. Проверьте количество готовых и доступных реплик.
5. Просмотрите события пространства имён.
6. Определите, какие события возникали при создании, удалении и обновлении Pod.
7. Проверьте состояние Metrics Server.
8. Запустите серию HTTP-запросов к приложению.
9. Повторно получите метрики использования ресурсов.
10. Сравните показатели до и после нагрузки.

Отметьте, что Metrics Server предоставляет текущие ресурсные метрики, но не является полноценной системой долговременного хранения истории мониторинга.

### Шаг 10. Журналирование и диагностика

1. Выберите один из Pod стабильного Deployment.
2. Получите журналы контейнера Nginx.
3. Выполните несколько HTTP-запросов к приложению.
4. Повторно просмотрите журналы.
5. Найдите записи о выполненных HTTP-запросах.
6. Получите журналы всех Pod, относящихся к приложению.
7. Проверьте события Deployment и отдельных Pod.
8. Создайте диагностический HTTP-запрос к несуществующему пути `/missing-page`.
9. Найдите соответствующую запись об ошибке `404` в журналах.
10. Объясните разницу между журналами приложения, событиями Kubernetes и метриками ресурсов.

### Шаг 11. Завершение работы и проверка воспроизводимости

1. Удалите Canary Deployment.
2. Проверьте, что Service продолжает направлять запросы к стабильной версии приложения.
3. Убедитесь, что стабильно работают три реплики.
4. Проверьте наличие файла в постоянном хранилище.
5. Удалите стабильный Deployment и Service.
6. Повторно разверните их из YAML-файлов.
7. Убедитесь, что приложение вновь доступно.
8. Проверьте сохранность данных в PVC.
9. Подготовьте отчёт и скриншоты основных этапов.
10. После сохранения результатов удалите учебные ресурсы, если это требуется правилами учебного стенда.

Не удаляйте PVC до проверки сохранности данных. Удаление PVC может привести к удалению связанного тома и содержащихся в нём файлов.

---

## Подсказки по ключевым частям

### Проверка K3s и создание пространства имён

```bash
sudo systemctl status k3s
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -A
sudo k3s kubectl get storageclass
sudo k3s kubectl create namespace lab3
```

Далее во всех командах управления учебными объектами используйте пространство имён `lab3`.

### Создание ConfigMap

Создайте файл `configmaps.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lab3-page-v1
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head><meta charset="UTF-8"></head>
    <body>
      <h1>VERSION 1</h1>
      <p>Stable application</p>
    </body>
    </html>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: lab3-page-v2
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head><meta charset="UTF-8"></head>
    <body>
      <h1>VERSION 2</h1>
      <p>Canary application</p>
    </body>
    </html>
```

Примените конфигурацию:

```bash
sudo k3s kubectl -n lab3 apply -f configmaps.yaml
sudo k3s kubectl -n lab3 get configmaps
```

### Создание стабильного Deployment

Создайте файл `deploy-stable.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab3-web-stable
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: lab3-web
      track: stable
  template:
    metadata:
      labels:
        app: lab3-web
        track: stable
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 2
            periodSeconds: 5
          volumeMounts:
            - name: web-page
              mountPath: /usr/share/nginx/html/index.html
              subPath: index.html
              readOnly: true
      volumes:
        - name: web-page
          configMap:
            name: lab3-page-v1
```

В этом примере HTML-страница находится в ConfigMap, а не внутри пользовательского Docker-образа. Для обновления можно изменить ссылку на ConfigMap и применить Deployment повторно.

Обратите внимание: файлы ConfigMap, подключённые через `subPath`, не обновляются автоматически в работающем контейнере. Поэтому для смены версии необходимо обновить шаблон Pod.

### Создание Service

Создайте файл `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lab3-web
spec:
  type: ClusterIP
  selector:
    app: lab3-web
  ports:
    - port: 80
      targetPort: 80
```

Примените манифесты:

```bash
sudo k3s kubectl -n lab3 apply -f deploy-stable.yaml
sudo k3s kubectl -n lab3 apply -f service.yaml

sudo k3s kubectl -n lab3 get pods
sudo k3s kubectl -n lab3 get svc
sudo k3s kubectl -n lab3 get endpointslices
```

### Проверка DNS

Создайте диагностический Pod:

```bash
sudo k3s kubectl -n lab3 run dns-check \
  --image=busybox:1.36 \
  --restart=Never -- sleep 36000
```

После перехода Pod в состояние `Running` выполните:

```bash
sudo k3s kubectl -n lab3 exec dns-check -- \
  nslookup lab3-web.lab3.svc.cluster.local

sudo k3s kubectl -n lab3 exec dns-check -- \
  wget -qO- http://lab3-web
```

Корректный ответ должен содержать текст `VERSION 1`.

### Создание PersistentVolumeClaim

Создайте файл `pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lab3-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
```

Примените:

```bash
sudo k3s kubectl -n lab3 apply -f pvc.yaml
sudo k3s kubectl -n lab3 get pvc
sudo k3s kubectl get pv
```

Если PVC временно находится в состоянии `Pending`, это может быть нормальным поведением StorageClass с режимом `WaitForFirstConsumer`. После создания использующего PVC Pod проверьте состояние повторно.

### Создание Secret и Pod с постоянным хранилищем

Создайте учебный Secret:

```bash
printf '%s' 'training-demo-only' | \
sudo k3s kubectl -n lab3 create secret generic lab3-secret \
  --from-file=token=/dev/stdin
```

Создайте `storage-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lab3-storage
spec:
  containers:
    - name: storage
      image: busybox:1.36
      command: ["sh", "-c", "sleep 36000"]
      env:
        - name: LAB_TOKEN
          valueFrom:
            secretKeyRef:
              name: lab3-secret
              key: token
      volumeMounts:
        - name: data-volume
          mountPath: /data
  volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: lab3-data
```

Примените манифест:

```bash
sudo k3s kubectl -n lab3 apply -f storage-pod.yaml
```

Создайте файл в постоянном хранилище:

```bash
sudo k3s kubectl -n lab3 exec lab3-storage -- \
  sh -c 'echo "Persistent data test" > /data/test.txt'
```

Проверьте его содержимое:

```bash
sudo k3s kubectl -n lab3 exec lab3-storage -- \
  cat /data/test.txt
```

Проверьте наличие Secret без вывода его значения:

```bash
sudo k3s kubectl -n lab3 exec lab3-storage -- \
  sh -c 'test -n "$LAB_TOKEN" && echo "Secret injected"'
```

Затем удалите Pod и создайте заново:

```bash
sudo k3s kubectl -n lab3 delete pod lab3-storage
sudo k3s kubectl -n lab3 apply -f storage-pod.yaml
```

После перехода Pod в `Running` повторно прочитайте `/data/test.txt`.

**Важно:** Secret не является гарантированно зашифрованным хранилищем сам по себе. Кодирование Base64 не обеспечивает защиту. Не включайте реальные токены, пароли и административные kubeconfig в отчёт или архив проекта.

### Настройка Canary Deployment

Создайте файл `deploy-canary.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lab3-web-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: lab3-web
      track: canary
  template:
    metadata:
      labels:
        app: lab3-web
        track: canary
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 2
            periodSeconds: 5
          volumeMounts:
            - name: web-page
              mountPath: /usr/share/nginx/html/index.html
              subPath: index.html
              readOnly: true
      volumes:
        - name: web-page
          configMap:
            name: lab3-page-v2
```

Примените:

```bash
sudo k3s kubectl -n lab3 apply -f deploy-canary.yaml

sudo k3s kubectl -n lab3 get deployments
sudo k3s kubectl -n lab3 get pods --show-labels
```

Проверьте наличие четырёх готовых Pod перед тестированием.

Для серии запросов:

```bash
sudo k3s kubectl -n lab3 exec dns-check -- sh -c '
i=0
while [ "$i" -lt 20 ]; do
  wget -qO- http://lab3-web | grep VERSION
  i=$((i+1))
done
'
```

Запишите, сколько раз была получена каждая версия. На небольшом количестве запросов результат может заметно отличаться от пропорции 3:1.

### Rolling Update и откат

В `deploy-stable.yaml` замените:

```yaml
configMap:
  name: lab3-page-v1
```

на:

```yaml
configMap:
  name: lab3-page-v2
```

Примените изменение:

```bash
sudo k3s kubectl -n lab3 apply -f deploy-stable.yaml

sudo k3s kubectl -n lab3 rollout status \
  deployment/lab3-web-stable

sudo k3s kubectl -n lab3 rollout history \
  deployment/lab3-web-stable
```

Для отката:

```bash
sudo k3s kubectl -n lab3 rollout undo \
  deployment/lab3-web-stable
```

Проверьте состояние:

```bash
sudo k3s kubectl -n lab3 get pods
sudo k3s kubectl -n lab3 get replicasets
sudo k3s kubectl -n lab3 describe deployment lab3-web-stable
```

После отката восстановите ссылку `lab3-page-v1` в локальном файле манифеста, чтобы последующее применение конфигурации не возвращало вторую версию.

### Мониторинг и журналы

```bash
sudo k3s kubectl top nodes
sudo k3s kubectl -n lab3 top pods

sudo k3s kubectl -n lab3 get events \
  --sort-by=.metadata.creationTimestamp

sudo k3s kubectl -n lab3 logs \
  -l app=lab3-web \
  --prefix=true \
  --max-log-requests=10 \
  --tail=30
```

Если `kubectl top` недоступен, проверьте состояние Metrics Server. Не устанавливайте его повторно без проверки существующих компонентов.

Для генерации ошибки `404`:

```bash
sudo k3s kubectl -n lab3 exec dns-check -- \
  wget -O- http://lab3-web/missing-page
```

Команда может завершиться с ненулевым кодом, поскольку сервер возвращает ошибку HTTP. Это ожидаемый результат диагностического эксперимента.

---

## Что изменить, чтобы выполнить работу на Kubernetes (K8s) вместо K3s

K3s является полноценным дистрибутивом Kubernetes, поэтому объекты Deployment, Service, ConfigMap, Secret, PVC и команды управления ими сохраняют своё назначение. Для выполнения работы в обычном Kubernetes-кластере, например созданном через `kubeadm`, внесите следующие изменения.

### 1. Заменить команды K3s

Вместо:

```bash
sudo k3s kubectl -n lab3 get pods
```

используйте:

```bash
kubectl -n lab3 get pods
```

Таким образом необходимо изменить все команды лабораторной работы, заменив `sudo k3s kubectl` на `kubectl`.

Перед выполнением убедитесь, что `kubectl` настроен на подключение к нужному кластеру.

### 2. Проверить сетевой плагин

В K3s по умолчанию обычно используется Flannel, а CoreDNS устанавливается автоматически.

В обычном Kubernetes-кластере необходимо убедиться, что установлен совместимый CNI-плагин, например Calico, Cilium или Flannel.

Проверьте:

```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl cluster-info
```

Если Pod не могут взаимодействовать по сети или DNS-запросы не выполняются, проверьте состояние CNI и CoreDNS.

YAML-манифесты Service изменять не требуется.

### 3. Заменить StorageClass

В K3s используется:

```yaml
storageClassName: local-path
```

В другом Kubernetes-кластере StorageClass может называться иначе.

Получите список:

```bash
kubectl get storageclass
```

Замените `local-path` в `pvc.yaml` на подходящий StorageClass, поддерживающий динамическое выделение томов. Если такого класса нет, предварительно настройте провайдер хранения либо создайте подходящий PersistentVolume вручную.

Не предполагайте, что PVC будет автоматически работать в любом кластере без настройки подсистемы хранения.

### 4. Проверить Metrics Server

В стандартной установке K3s Metrics Server обычно присутствует.

В Kubernetes, развёрнутом через `kubeadm`, Metrics Server может отсутствовать.

Проверьте:

```bash
kubectl -n kube-system get deployment metrics-server
kubectl top nodes
```

Если Metrics Server отсутствует, установите совместимую версию по официальной документации. Без работающего Metrics Server команды `kubectl top` не смогут показать ресурсные метрики.

### 5. Проверить доступность реплик

При использовании нескольких узлов необходимо убедиться, что сетевые политики, настройки CNI и правила размещения Pod допускают взаимодействие приложения.

Для StorageClass с локальными томами учитывайте привязку данных к конкретному узлу. В распределённом кластере для отказоустойчивого хранения может потребоваться сетевое или распределённое хранилище.

### 6. Сохранить настройки Canary и Rolling Update

Файлы `configmaps.yaml`, `service.yaml`, `deploy-stable.yaml` и `deploy-canary.yaml` в общем случае не требуют изменений.

Принципы работы Service Discovery, Canary Deployment, Rolling Update, ConfigMap и Secret остаются одинаковыми.

**Итог:** для перехода с K3s на кластер Kubernetes через `kubeadm` необходимо проверить и при необходимости настроить CNI, StorageClass, Metrics Server и доступ `kubectl`. Логика лабораторной работы остаётся прежней.

---

## Что проверить перед отправкой (чек-лист)

- [ ] Кластер K3s работает корректно.
- [ ] Создано пространство имён `lab3`.
- [ ] Настроены Deployment и Service.
- [ ] DNS успешно разрешает имя Kubernetes Service.
- [ ] Проверен HTTP-доступ к приложению внутри кластера.
- [ ] Созданы две ConfigMap с разными версиями страницы.
- [ ] Создан PersistentVolumeClaim объёмом `1Gi`.
- [ ] PVC перешёл в состояние `Bound`.
- [ ] Данные сохранились после удаления и повторного создания Pod.
- [ ] Создан Secret и проверено его подключение.
- [ ] Создан стабильный Deployment с тремя репликами.
- [ ] Создан Canary Deployment с одной репликой.
- [ ] Проверено получение ответов от двух версий приложения.
- [ ] Выполнен Rolling Update.
- [ ] Проверены ReplicaSet и история обновлений.
- [ ] Выполнен откат Deployment.
- [ ] Получены метрики CPU и оперативной памяти.
- [ ] Проверены журналы Nginx и события Kubernetes.
- [ ] Проект повторно развёрнут из YAML-манифестов.
- [ ] Подготовлены необходимые скриншоты и отчёт.

## Советы по улучшению работы

**Контролируйте готовность приложений.** Используйте `readinessProbe`, чтобы Service направлял запросы только к Pod, готовым обслуживать HTTP-трафик. Для приложений, требующих более длительной инициализации, подберите соответствующие параметры проверок.

**Разделяйте конфигурацию и приложение.** Используйте ConfigMap для обычных параметров, а Secret — для конфиденциальных данных. Не размещайте реальные пароли и токены в публичных репозиториях.

**Учитывайте ограничения Canary Deployment.** Соотношение реплик не обеспечивает точного процентного распределения HTTP-запросов. Для управляемого разделения трафика можно дополнительно изучить возможности Ingress-контроллеров, Gateway API и сервисных сетей.

**Контролируйте сохранность данных.** Проверяйте, что удаление Pod не приводит к потере данных. Для рабочих систем учитывайте политику освобождения томов, резервное копирование и отказоустойчивость хранилища.

**Используйте конкретные версии образов.** Для воспроизводимых развёртываний закрепляйте версии или digest образов. Изменяемые теги вроде `nginx:alpine` удобны для учебных экспериментов, но затрудняют точное воспроизведение результата.

**Улучшайте наблюдаемость.** Помимо `kubectl top` и `kubectl logs`, изучите возможности Prometheus, Grafana и систем централизованного сбора журналов. Они позволяют хранить историю метрик, строить графики и настраивать оповещения.

## Вопросы для рефлексии

1. **Почему Kubernetes использует Service Discovery, а не постоянное обращение к IP-адресам Pod?** Что произойдёт при пересоздании Pod и как CoreDNS помогает избежать проблем с доступностью приложения?

2. **Чем отличаются PersistentVolume, PersistentVolumeClaim и StorageClass?** Почему данные сохранились после удаления Pod и при каких условиях они могут быть потеряны?

3. **Почему ConfigMap и Secret представлены разными объектами Kubernetes?** Какие преимущества даёт хранение конфигурации отдельно от контейнерного образа и какие дополнительные меры необходимы для защиты секретных данных?

4. **В чём различие между Rolling Update и Canary Deployment?** Какую стратегию целесообразнее использовать для обновления критически важного приложения и какие дополнительные механизмы потребуются для безопасного развёртывания?

5. **Каким образом метрики, журналы и события Kubernetes помогают находить неисправности?** Представьте, что после обновления приложения часть запросов возвращает ошибку `500`. Какие данные необходимо проверить и в какой последовательности?

## Результат выполнения лабораторной работы

Подготовьте архив `k8s-lab3.zip`, содержащий:

- `configmaps.yaml` — конфигурации двух версий приложения.
- `deploy-stable.yaml` — стабильный Deployment.
- `deploy-canary.yaml` — Canary Deployment.
- `service.yaml` — конфигурация Service.
- `pvc.yaml` — описание постоянного хранилища.
- `storage-pod.yaml` — Pod для проверки постоянного хранения и использования Secret.
- `README.md` — инструкция по запуску, результаты экспериментов и выводы.
- `reflection.md` — ответы на пять вопросов для рефлексии.
- `screenshots/` — скриншоты выполненных этапов.

В `README.md` обязательно укажите результаты DNS-проверок, состояние PV и PVC, результаты эксперимента Canary Deployment, порядок Rolling Update и отката, показатели мониторинга и обнаруженные события Kubernetes.

Не включайте в архив действующие секретные значения или файлы с административными учётными данными кластера. Учебный Secret должен создаваться отдельно по инструкции.

**Критерий успешного выполнения:** преподаватель должен иметь возможность воспроизвести развёртывание двух версий приложения, проверить Service Discovery, подтвердить сохранность данных после пересоздания Pod, выполнить Canary Deployment, Rolling Update и откат, а также получить метрики и журналы работающего приложения.
