# 🤖 Bot Mirza Panel

This repository is a fork of the original repository https://github.com/mahdiMGF2/mirzabot.git. You can find all the details and documentation about the bot on the original author's page. Here we only provide three scripts to make it easier for you to work with:





## 🚀 One-line Usage Commands
### Installation Script:
[installer.sh](https://github.com/thugbit/mirza_pro_easy_install/blob/main/installer.sh)
### Install:
```bash
curl -fsSL https://raw.githubusercontent.com/thugbit/mirza_pro_easy_install/main/installer.sh | bash
```

### Backup Script:
[backup.sh](https://github.com/thugbit/mirza_pro_easy_install/blob/main/backup.sh)
### Backup:
```bash
curl -fsSL https://raw.githubusercontent.com/thugbit/mirza_pro_easy_install/main/backup.sh | bash
```

### Restore Backup Script:
[restore_backup.sh](https://github.com/thugbit/mirza_pro_easy_install/blob/main/restore_backup.sh)
### Restore:
```bash
curl -fsSL https://raw.githubusercontent.com/thugbit/mirza_pro_easy_install/main/restore_backup.sh | bash
```

## ⚠️ Important Notes for Restoration

1️⃣ If database root has password → you need to add `-p`
2️⃣ If domain changes → old SSL certificate may not work
3️⃣ If IP changes → Telegram webhook needs to be set again

After restore, you can run:

```bash
php /var/www/mirza_pro/table.php
```

And reconfigure the webhook.

