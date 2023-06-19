#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

# Only execute if installed
if [ -f /notinstalled ]; then exit 0; fi

# Inform if new version available
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

# Updater code
bashio::log.green "Checking for nextcloud updates"
# Install new version
sudo -u abc -s /bin/bash -c "php /data/config/www/nextcloud/updater/updater.phar --no-interaction"
sudo -u abc -s /bin/bash -c "php /data/config/www/nextcloud/occ upgrade"
# Install additional versions
while [[ $(occ update:check 2>&1) == *"update available"* ]]; do
    bashio::log.yellow "-----------------------------------------------------------------------"
    bashio::log.yellow "  new version available, updating. Please do not turn off your addon!  "
    bashio::log.yellow "-----------------------------------------------------------------------"
    sudo -u abc -s /bin/bash -c "php /data/config/www/nextcloud/updater/updater.phar --no-interaction"
    sudo -u abc -s /bin/bash -c "php /data/config/www/nextcloud/occ upgrade"
done
    
if ! bashio::config.true "disable_updates"; then
    bashio::log.green "---"
    bashio::log.green "Updating apps"
    sudo -u abc -s /bin/bash -c "php /data/config/www/nextcloud/occ app:update --all"
else
    bashio::log.green "disable_updates set, please update the apps manually"
fi

# Reset permissions
/./etc/cont-init.d/01-folders.sh
