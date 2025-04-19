#!/bin/bash
while true; do
    php -f /var/www/html/cron.php
    sleep 300 # 5分ごとに実行
done
