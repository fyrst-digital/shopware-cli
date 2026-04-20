#!/usr/bin/env sh
set -euo pipefail

# Start MariaDB
mkdir -p /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=root --datadir=/var/lib/mysql >/dev/null 2>&1
fi

echo "Starting MariaDB..."
mariadbd --user=root --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock &

echo "Waiting for MariaDB to be ready..."
until mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent 2>/dev/null; do
    sleep 1
done
echo "MariaDB is ready."

# Create app user for TCP connections (root uses unix_socket auth only)
mariadb --socket=/run/mysqld/mysqld.sock -u root -e "CREATE USER IF NOT EXISTS 'shopware'@'127.0.0.1' IDENTIFIED BY 'shopware'; GRANT ALL PRIVILEGES ON *.* TO 'shopware'@'127.0.0.1'; FLUSH PRIVILEGES;"

# Create Shopware project if not present
if [ ! -f /app/composer.json ]; then
    echo "Shopware not found in /app, installing..."
    if [ -n "${SHOPWARE_VERSION:-}" ]; then
        composer create-project "shopware/production:${SHOPWARE_VERSION}" /app
    else
        composer create-project shopware/production /app
    fi
    echo "Shopware project created."
fi

# Install Shopware if not yet installed
if [ ! -f /app/install.lock ]; then
    echo "Installing Shopware..."

    composer install --quiet --no-interaction --working-dir=/app

    composer require --dev shopware/dev-tools --no-interaction --working-dir=/app

    sed -i 's|^DATABASE_URL=.*|DATABASE_URL="mysql://shopware:shopware@127.0.0.1:3306/shopware"|' /app/.env

    bin/console system:install \
        --create-database \
        --basic-setup \
        --shop-name="Dev Shop" \
        --shop-email="dev@example.com" \
        --shop-locale="en-GB" \
        --shop-currency="EUR" \
        --skip-first-run-wizard \
        -n

    bin/console framework:demodata -n --orders=0

    echo "Shopware installation complete."
fi

# Write Caddyfile
cat > /etc/caddy/Caddyfile <<'CADDYFILE'
{
    admin off
}

:8000 {
    root * /app/public
    encode gzip
    php_fastcgi 127.0.0.1:9000
    file_server
}
CADDYFILE

# Configure PHP-FPM for /app
rm -f /etc/php/php-fpm.d/www.conf /etc/php/php-fpm.d/zz-apko.conf
cat > /etc/php/php-fpm.d/dev.conf <<'FPMCONF'
[dev]
user = root
group = root
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /app
clear_env = no
FPMCONF

# Start PHP-FPM
echo "Starting PHP-FPM..."
php-fpm --allow-to-run-as-root -D

# Run Caddy in foreground
echo "Starting Caddy on :8000..."
exec caddy run
