#!/usr/bin/env bash
set -Eeuo pipefail

echo "==== Mirza Pro Full Backup Script (Stable Version) ===="

CONFIG_PATH="/var/www/mirza_pro/config.php"
PROJECT_PATH="/var/www/mirza_pro"
APACHE_CONF="/etc/apache2/sites-available/mirza-pro.conf"
LETSENCRYPT_PATH="/etc/letsencrypt"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/root/mirza_backup_${TIMESTAMP}"
ARCHIVE_PATH="${BACKUP_DIR}.tar.gz"
LOG_FILE="/root/mirza_backup_${TIMESTAMP}.log"

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "==> Checking config.php ..."
if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "ERROR: config.php not found at $CONFIG_PATH"
  exit 1
fi

echo "==> Extracting database credentials ..."

DB_NAME=$(awk -F"'" '/\$dbname[[:space:]]*=/{print $2; exit}' "$CONFIG_PATH")
DB_USER=$(awk -F"'" '/\$usernamedb[[:space:]]*=/{print $2; exit}' "$CONFIG_PATH")
DB_PASS=$(awk -F"'" '/\$passworddb[[:space:]]*=/{print $2; exit}' "$CONFIG_PATH")

if [[ -z "${DB_NAME:-}" || -z "${DB_USER:-}" ]]; then
  echo "ERROR: Failed to extract DB credentials from config.php"
  exit 1
fi

echo "Database detected: $DB_NAME"
echo "DB User detected: $DB_USER"

echo "==> Testing database connection ..."
if ! mysql -u"$DB_USER" -p"$DB_PASS" -e "USE \`$DB_NAME\`;" >/dev/null 2>&1; then
  echo "ERROR: Cannot connect to database."
  exit 1
fi

echo "Database connection OK"

echo "==> Dumping database ..."
mysqldump -u"$DB_USER" -p"$DB_PASS" \
  --single-transaction \
  --quick \
  --lock-tables=false \
  "$DB_NAME" > "$BACKUP_DIR/database.sql"

echo "Database dump completed"

echo "==> Copying project files ..."
cp -a "$PROJECT_PATH" "$BACKUP_DIR/"

echo "==> Backing up Apache config (if exists) ..."
[[ -f "$APACHE_CONF" ]] && cp "$APACHE_CONF" "$BACKUP_DIR/"

echo "==> Backing up SSL certificates (if exists) ..."
[[ -d "$LETSENCRYPT_PATH" ]] && cp -a "$LETSENCRYPT_PATH" "$BACKUP_DIR/"

echo "==> Backing up crontab ..."
crontab -l > "$BACKUP_DIR/crontab.txt" 2>/dev/null || true

echo "==> Creating compressed archive ..."
tar -czf "$ARCHIVE_PATH" -C /root "$(basename "$BACKUP_DIR")"

echo "==> Cleaning temporary files ..."
rm -rf "$BACKUP_DIR"

chmod 600 "$ARCHIVE_PATH"

echo ""
echo "✅ Backup successfully created:"
echo "$ARCHIVE_PATH"
echo "Log file:"
echo "$LOG_FILE"
