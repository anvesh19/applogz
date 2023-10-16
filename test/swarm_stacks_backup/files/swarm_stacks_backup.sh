#!/usr/bin/env bash

set -x

set -e

TOKEN_DEV=$( curl --noproxy '*' -XPOST -s --insecure \-H 'Content-Type: application/json' \-d '{"username": "ansible", "password": "{{ portainer_password }}"}' "https://portainer.dev.sdil.aorta.net/api/auth" | jq --raw-output '.jwt' )

TOKEN_PROD=$( curl --noproxy '*' -XPOST -s --insecure \-H 'Content-Type: application/json' \-d '{"username": "ansible", "password": "{{ portainer_password }}"}' "https://portainer.sdil.aorta.net/api/auth" | jq --raw-output '.jwt' )

curl --noproxy '*' -H "Authorization: $TOKEN_DEV" https://portainer.dev.sdil.aorta.net/api/stacks\?filters\=%7B%22SwarmID%22:%22m3v02wbjy0bo65neplilfsimh%22%7D | jq . > /home/ansible/git/obs-swarm-stack-backups/dev-swarm/id_name_map

curl --noproxy '*' -H "Authorization: $TOKEN_PROD" https://portainer.sdil.aorta.net/api/stacks?filters=%7B%22SwarmID%22:%22tdryxtb3s62lc86bl3c6tf57v%22%7D | jq . > /home/ansible/git/obs-swarm-stack-backups/prod-swarm/id_name_map

#curl --noproxy '*' -H "Authorization: $TOKEN_KBW" https://portainer-kbw.sdil.aorta.net/api0/stacks?filters=%7B%22SwarmID%22:%22iue33e3q8k5r94ek627qtojeb%22%7D | jq . > /home/ansible/git/obs-swarm-stack-backups/kbw-swarm/id_name_map


scp -r root@172.16.188.80:/mnt/dev_sdil_docker_vols/portainer/portainer_portainer/compose /home/ansible/git/obs-swarm-stack-backups/dev-swarm/

scp -r root@172.23.101.227:/mnt/prod_sdil_docker_vols/portainer/portainer_portainer/compose /home/ansible/git/obs-swarm-stack-backups/prod-swarm/

#scp -r root@172.31.141.198:/mnt/nfs/bmswarm_vols/portainer/portainer_portainer/compose /home/ansible/git/obs-swarm-stack-backups/kbw-swarm/



### PUSH TO GIT ###
 
 cd /home/ansible/git/obs-swarm-stack-backups
 echo "INFO: Update git repository"
 git pull 
 echo "INFO: Commit changes" 
 git add . 
 set +e
 git commit -m "There are changes in Swarm stacks" 
 set -e
 echo "INFO: Push changes to git repository" 
 git push