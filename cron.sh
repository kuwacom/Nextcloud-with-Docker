#!/bin/bash
sleep 30 # wait for Nextcloud to start

# docker compose up で再生成したときに実行
php /var/www/html/occ maintenance:update:htaccess

while true; do
    echo "Running cron job at $(date)"
    php -f /var/www/html/cron.php
    sleep 300 # 5分ごとに実行
done
