#!/usr/bin/env bash
set -e

echo "==== Mirza Pro Full Backup Script ===="

BACKUP_DIR="/root/mirza_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "==> Detecting database name from config.php ..."

CONFIG_PATH="/var/www/mirza_pro/config.php"

if [ ! -f "$CONFIG_PATH" ]; then
  echo "config.php not found! Exiting."
  exit 1
fi

DB_NAME=$(grep "\$dbname" $CONFIG_PATH | cut -d"'" -f2)
DB_USER=$(grep "\$usernamedb" $CONFIG_PATH | cut -d"'" -f2)
DB_PASS=$(grep "\$passworddb" $CONFIG_PATH | cut -d"'" -f2)

echo "Database detected: $DB_NAME"

echo "==> Dumping database ..."
mysqldump -u root "$DB_NAME" > "$BACKUP_DIR/database.sql"

echo "==> Copying project files ..."
cp -r /var/www/mirza_pro "$BACKUP_DIR/"

echo "==> Backing up Apache config ..."
cp /etc/apache2/sites-available/mirza-pro.conf "$BACKUP_DIR/" 2>/dev/null || true

echo "==> Backing up SSL certificates ..."
cp -r /etc/letsencrypt "$BACKUP_DIR/" 2>/dev/null || true

echo "==> Backing up crontab ..."
crontab -l > "$BACKUP_DIR/crontab.txt" 2>/dev/null || true

echo "==> Creating compressed archive ..."
tar -czf "${BACKUP_DIR}.tar.gz" -C /root "$(basename $BACKUP_DIR)"

rm -rf "$BACKUP_DIR"

echo "Backup created:"
echo "${BACKUP_DIR}.tar.gz"
