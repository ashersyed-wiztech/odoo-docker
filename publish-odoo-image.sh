#!/bin/bash

set -x

curl --header "PRIVATE-TOKEN: RRB-5Wesw99zMd3sjpxm" 'http://172.19.53.32/api/v4/projects' -o projects.json
curl --header "PRIVATE-TOKEN: RRB-5Wesw99zMd3sjpxm" 'http://172.19.53.32/api/v4/projects/1/jobs?scope[]=success' -o jobs.json

#ARTIFACTS_URL=$(cat jobs.json |  jq '.[1].web_url')
#ARTIFACTS_URL=${ARTIFACTS_URL//\"/}
#ARTIFACTS_URL=${ARTIFACTS_URL}/artifacts/download
ARTIFACTS_URL="http://172.19.53.32/api/v4/projects/1/jobs/artifacts/12.0/download?job=job"
pushd 12.0/

docker build --build-arg ARTIFACTS_URL="$ARTIFACTS_URL" -t registry.cn-shanghai.aliyuncs.com/silu-design/odoo:12 .
echo $REGISTRYPASS | docker login --username=$REGISTRYUSER --password-stdin registry.cn-shanghai.aliyuncs.com
docker push registry.cn-shanghai.aliyuncs.com/silu-design/odoo:12

popd

set +x