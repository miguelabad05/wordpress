#!/bin/bash

DOMAIN="tudominio.com"
EMAIL="admin@tudominio.com"
APACHE_CONF="/etc/apache2/sites-available/${DOMAIN}.conf"

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este script debe ejecutarse como root."
        exit 1
    fi
}

install_dependencies() {
    echo "Instalando dependencias necesarias..."
    apt update
    apt install -y certbot python3-certbot-apache apache2
}

enable_apache_modules() {
    echo "Habilitando módulos de Apache..."
    a2enmod ssl
    a2enmod rewrite
    a2enmod headers
    systemctl restart apache2
}

request_certificate() {
    echo "Solicitando certificado SSL/TLS para $DOMAIN..."
    certbot --apache -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect
}

setup_auto_renewal() {
    echo "Configurando auto-renovación de certificados..."
    systemctl enable certbot.timer
    systemctl start certbot.timer
}

# --- Ejecución ---
check_root
install_dependencies
enable_apache_modules
request_certificate
setup_auto_renewal

echo "✅ Certificado SSL/TLS de Let's Encrypt instalado y configurado en Apache para $DOMAIN"
