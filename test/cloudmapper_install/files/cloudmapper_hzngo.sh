#!/bin/bash

export http_proxy="http://172.31.141.196:3128"
export https_proxy="http://172.31.141.196:3128"

cd /home/ansible/git/cloudmapper

/usr/local/bin/python3.7 -m venv ./venv && source venv/bin/activate

python cloudmapper.py collect --account hzngo --profile hzngo --regions eu-central-1,eu-west-1,eu-west-2,eu-west-3,eusouth-1,eu-north-1 --clean --config config.json

python convert_aws_data_to_single_json.py --account hzngo

scp /home/ansible/git/cloudmapper/aws_single_json_output/hzngo_aws_data.json ansible@172.16.188.88:/tmp

ssh ansible@172.16.188.88 sudo mv /tmp/hzngo_aws_data.json /data/cloudmapper/unprocessed

scp /home/ansible/git/cloudmapper/aws_single_json_output/hzngo_aws_data.json ansible@172.16.188.95:/tmp

ssh ansible@172.16.188.95 "sudo mkdir -p /home/observer/prod/model-topology/data && sudo mv /tmp/hzngo_aws_data.json /home/observer/prod/model-topology/data"