#!/bin/bash

DB_NAME="wordpress_db"
DB_USER="wp_user"
DB_PASS="TuContraseñaSeguraAqui"
DB_ROOT_PASS="ContraseñaRootMySQL" 

WEB_ROOT="/var/www/html"
WEB_USER="www-data"

echo "=== Inicio del Despliegue de WordPress ==="

echo "2. Comprobando e instalando dependencias (wget, unzip)..."
sudo apt update
sudo apt install -y wget unzip

echo "3. Limpiando el directorio raíz: $WEB_ROOT"
sudo rm -rf "$WEB_ROOT"/*
sudo rm -rf "$WEB_ROOT"/.* 2>/dev/null

echo "   Descargando la última versión de WordPress..."
wget -q "https://wordpress.org/latest.tar.gz" -O /tmp/latest.tar.gz

echo "   Extrayendo archivos..."
tar -xzf /tmp/latest.tar.gz -C /tmp/

echo "   Moviendo archivos al directorio $WEB_ROOT..."
sudo mv /tmp/wordpress/* "$WEB_ROOT"/

rm /tmp/latest.tar.gz
rm -rf /tmp/wordpress

echo "4. Creando la base de datos y usuario de MySQL/MariaDB..."

MYSQL_COMMANDS=$(cat <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
)

echo "$MYSQL_COMMANDS" | sudo mysql -u root -p"$DB_ROOT_PASS"

if [ $? -ne 0 ]; then
    echo "!!! ERROR: No se pudo conectar a MySQL o crear la base de datos."
    echo "!!! Por favor, verifica la contraseña de root de MySQL (\$DB_ROOT_PASS)."
    exit 1
fi

echo "   Base de datos: $DB_NAME y Usuario: $DB_USER creados exitosamente."

echo "5. Creando el archivo wp-config.php..."

cd "$WEB_ROOT"

sudo cp wp-config-sample.php wp-config.php

echo "   Generando claves de seguridad (SALTS)..."
SALT_KEYS=$(wget -q -O - https://api.wordpress.org/secret-key/1.1/salt/)

echo "   Sustituyendo credenciales y claves de seguridad..."
sudo sed -i "s/database_name_here/$DB_NAME/g" wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" wp-config.php
sudo sed -i "s/password_here/$DB_PASS/g" wp-config.php

sudo sed -i "/#@\+?P/r /dev/stdin" wp-config.php <<< "$SALT_KEYS"
sudo sed -i "/#@\+?P/,+8d" wp-config.php

echo "6. Estableciendo permisos correctos para $WEB_USER..."

sudo chown -R $WEB_USER:$WEB_USER "$WEB_ROOT"

sudo find "$WEB_ROOT"/ -type d -exec chmod 755 {} \;
sudo find "$WEB_ROOT"/ -type f -exec chmod 644 {} \;

echo "=== Despliegue de WordPress Completado ==="
echo "Ahora puedes acceder a tu servidor en el navegador para finalizar la instalación web."
echo ""
echo "URL de Acceso: http://<DIRECCIÓN_IP_DE_TU_SERVIDOR>"
