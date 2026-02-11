#!/usr/bin/env bash
set -e

echo "==== Mirza Pro Full Restore Script ===="

read -p "Enter backup file path (example: /root/mirza_backup_xxx.tar.gz): " BACKUP_FILE

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found!"
  exit 1
fi

TMP_DIR="/root/mirza_restore_tmp"
mkdir -p "$TMP_DIR"

echo "==> Extracting backup ..."
tar -xzf "$BACKUP_FILE" -C "$TMP_DIR"

EXTRACTED_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "mirza_backup_*")

echo "==> Restoring project files ..."
rm -rf /var/www/mirza_pro
cp -r "$EXTRACTED_DIR/mirza_pro" /var/www/
chown -R www-data:www-data /var/www/mirza_pro

echo "==> Restoring Apache config ..."
cp "$EXTRACTED_DIR/mirza-pro.conf" /etc/apache2/sites-available/ 2>/dev/null || true
a2ensite mirza-pro.conf 2>/dev/null || true
systemctl reload apache2

echo "==> Restoring SSL ..."
cp -r "$EXTRACTED_DIR/letsencrypt" /etc/ 2>/dev/null || true

echo "==> Restoring database ..."
CONFIG_PATH="/var/www/mirza_pro/config.php"

DB_NAME=$(grep "\$dbname" $CONFIG_PATH | cut -d"'" -f2)

mysql -u root "$DB_NAME" < "$EXTRACTED_DIR/database.sql"

echo "==> Restoring crontab ..."
crontab "$EXTRACTED_DIR/crontab.txt" 2>/dev/null || true

rm -rf "$TMP_DIR"

echo "===== Restore Completed Successfully ====="
