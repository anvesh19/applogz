#!/usr/bin/env bash

### PULL FROM GIT ###

cd /home/ansible/git/obs-nginx-configs
echo "INFO: Update git repository"
git stash
git pull --rebase
git stash pop

set -e

rsync -rL --exclude '*.swp' ansible@172.31.141.200:/etc/nginx/sites-enabled /home/ansible/git/obs-nginx-configs/nl-ams02c-osi01

rsync -rL --exclude '*.swp' ansible@172.16.188.76:/etc/nginx/sites-enabled /home/ansible/git/obs-nginx-configs/vnl-ecx-prd-web01

rsync -rL --exclude '*.swp' ansible@172.16.188.90:/etc/nginx/sites-enabled /home/ansible/git/obs-nginx-configs/vnl-ecx-dev-web01

rsync -rL --exclude '*.swp' ansible@172.16.188.88:/etc/nginx/sites-enabled /home/ansible/git/obs-nginx-configs/pnl-ecx-prd-col06

rsync -rL --exclude '*.swp' ansible@172.23.101.223:/etc/nginx/sites-enabled /home/ansible/git/obs-nginx-configs/vnl-ecx-prd-inf01

### PUSH TO GIT ###

echo "INFO: Commit changes"
git add .
set +e
git commit -m "There are changes in Nginx configs"
set -e
echo "INFO: Push changes to git repository"
git push
