## Ходжаев Абдужалол
# Виртуальное окружение

>[!NOTE]
>Почему не использовать ещё один compose-скрипт?
>
>Хост уже находится в локальной сети 192.168.1.0/24. При создании bridge-сети с таким же адресным пространством возникают конфликты, а также отсутствует доступ в интернет, что создаст трудности

# Пример создания ВМ (на примере машины А)
## Шаг 1: Подготовка cloud-init файлов
Файлы `meta-data` и `user-data` используются для автоматической конфигурации ВМ при первом запуске.
В `meta-data` обычно указываются имя машины, идентификаторы и другие параметры, но этот файл может быть пустым.
В `user-data` настраиваются пользователи, сеть и другие параметры:
```yaml
#cloud-config
hostname: ubuntuA
fqdn: ubuntuA.local
manage_etc_hosts: true
# Пользователья по умолчанию нет. А у рута по умолчанию пароля нет
chpasswd:
    expire: false
    list: |
        ubuntu:ubuntu 
        root:root

ssh_pwauth: true
disable_root: false

network:
    version: 2
    ethernets:
        enp1s0:
            dhcp4: no
# Не забываем назначить ip по заданию
            addresses: [192.168.122.197/24]
            gateway4: 192.168.122.1
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]
```

>[!NOTE] 
>`cloud-init` — инструмент для автоматизации первичной настройки виртуальных машин.

## Шаг 2: Запуск скрипта создания
Что выполняет скрипт `new-ubuntu-A.sh`:
- Создаёт диск для ВМ на основе заранее загруженного cloudimg-образа.
- Генерирует cloud-init ISO из файлов meta-data и user-data.
- Создаёт и запускает виртуальную машину с помощью virt-install.

```bash
# Создание cloud-init ISO
cloud-localds \
    -v --network-config=user-data network-config-A.iso user-data meta-data

# Этот шаг можно пропустить, если пользователь состоит в группе libvirt
sudo mv network-config-A.iso /var/lib/libvirt/images/

# Создание диска qcow2. Преимущество формата — виртуальный диск может быть, например, 100 ГБ, но фактически занимает только используемое пространство.
sudo qemu-img create -f qcow2 \
    -b /var/lib/libvirt/images/ubuntu-24.04-server-cloudimg-amd64.img -F qcow2 \
    /var/lib/libvirt/images/ubuntuA.qcow2 20G

sudo virt-install \
    --name ubuntuA \
    --memory 8192 \
    --vcpus 2 \
    --disk /var/lib/libvirt/images/ubuntuA.qcow2,device=disk,bus=virtio \
    --disk path=/var/lib/libvirt/images/network-config-A.iso,device=cdrom \
    --os-variant ubuntu24.04 \
    --virt-type kvm \
    --graphics none \
    --network network=default,model=virtio \ # NAT-сеть по умолчанию libvirt (192.168.122.0/24)
    --import
```

## Шаг 3: Дополнительная настройка
После установки ВМ можно подключиться к ней и приступить к работе:
```bash
virsh console ubuntuA
``` 
Для машины А необходимо установить и настроить Docker и плагин для Docker Compose (`configure.sh`) согласно официальной инструкции:
```bash
apt update
apt install ca-certificates curl
install -m 0755 -d /usr/share/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

После установки выполним дополнительную настройку:
```bash
usermod -aG docker ubuntu # Добавить пользователя ubuntu в группу docker для работы без sudo

systemctl enable docker --now
```

# Комментарии
Повторяем шаги для машины Б. Шаг 3 можно не повторять. 

>[!NOTE]
>Можно было создать одну виртуальную машину и через бридж сеть назначить ей ip в локальной сети. Но тогда утерялась повторяемость задания на не-ubuntu хосте

# Ссылки
- [Пользователи в cloud-init](https://cloudinit.readthedocs.io/en/latest/reference/yaml_examples/set_passwords.html)
- [Мануал virt-install](https://man.archlinux.org/man/virt-install.1.en)
- [Инструкция по устновке docker в Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Работа с cloud init datasource](https://documentation.ubuntu.com/public-images/public-images-how-to/use-local-cloud-init-ds/)
- [Инструкция по qemu img](https://www.ibm.com/docs/en/linux-on-systems?topic=commands-qemu-image-command)