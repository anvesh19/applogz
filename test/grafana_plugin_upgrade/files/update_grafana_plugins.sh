#!/usr/bin/env bash

cd /mnt/dev_sdil_docker_vols/grafana03/grafana7/var/lib/grafana/plugins/

for dir in */;
do
    echo ""
	echo "$dir"
 	cd $dir
	git pull
	cd ..
	echo ""
done

sudo cp -r /mnt/dev_sdil_docker_vols/grafana03/grafana7/var/lib/grafana/plugins/ /mnt/dev_sdil_docker_vols/grafana03/grafana8/var/lib/grafana/


#grafana7
curl --noproxy '*' -X POST https://portainer.dev.sdil.aorta.net/api/webhooks/f14ae5a3-ed30-48f7-9851-3103995cc873

#grafana8:
curl --noproxy '*' -X POST https://portainer.dev.sdil.aorta.net/api/webhooks/35cb8220-af3f-41a0-aaed-e7a5467ef1ba