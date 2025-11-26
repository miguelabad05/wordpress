#!/bin/bash

# Actualizar paquetes
sudo apt update && sudo apt upgrade -y

# Instalar Apache
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

# Instalar MySQL (puedes cambiar por mariadb-server si prefieres MariaDB)
sudo apt install mysql-server -y
sudo systemctl enable mysql
sudo systemctl start mysql

# Ejecutar configuración segura de MySQL
sudo mysql_secure_installation

# Instalar PHP y módulos comunes
sudo apt install php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc php-zip -y

# Reiniciar Apache para aplicar cambios
sudo systemctl restart apache2

# Verificar instalación
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

Verificar PHP en http://localhost/info.php"
