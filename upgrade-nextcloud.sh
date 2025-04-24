docker exec -it nextcloud_app su www-data -s /bin/sh -c "
    php /var/www/html/occ maintenance:mode --on
    php /var/www/html/occ upgrade
    php /var/www/html/occ maintenance:mode --off
    php /var/www/html/occ maintenance:update:htaccess
"
