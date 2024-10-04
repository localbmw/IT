#!/bin/bash

# Спросим имя интерфейса
read -p "Введите имя Wi-Fi интерфейса (например, wlan0): " wifi_interface

# Спросим SSID (имя Wi-Fi сети)
read -p "Введите имя сети Wi-Fi (SSID): " ssid

# Спросим пароль от Wi-Fi сети
read -sp "Введите пароль от сети Wi-Fi: " wifi_password
echo

# Проверим наличие wpa_supplicant и wireless-tools
echo "Проверяем наличие необходимых пакетов..."
sudo apt update
sudo apt install -y wireless-tools wpasupplicant

# Создаем конфигурационный файл wpa_supplicant
echo "Создаем конфигурационный файл для wpa_supplicant..."
sudo bash -c "cat > /etc/wpa_supplicant/wpa_supplicant.conf" <<EOL
network={
    ssid="$ssid"
    psk="$wifi_password"
}
EOL

# Подключаемся к Wi-Fi
echo "Подключаемся к Wi-Fi..."
sudo wpa_supplicant -B -i $wifi_interface -c /etc/wpa_supplicant/wpa_supplicant.conf

# Получаем IP-адрес через DHCP
echo "Получаем IP-адрес через DHCP..."
sudo dhclient $wifi_interface

# Проверка подключения
echo "Проверяем подключение..."
ping -c 4 8.8.8.8

# Настройка автоматического подключения через netplan
echo "Настраиваем автоматическое подключение через netplan..."
netplan_file="/etc/netplan/01-netcfg.yaml"
sudo bash -c "cat > $netplan_file" <<EOL
network:
    version: 2
    renderer: networkd
    wifis:
        $wifi_interface:
            dhcp4: true
            access-points:
                "$ssid":
                    password: "$wifi_password"
EOL

# Применение настроек netplan
echo "Применяем конфигурацию netplan..."
sudo netplan apply

echo "Настройка завершена. Теперь ваш сервер будет автоматически подключаться к Wi-Fi при загрузке."

