#!/bin/bash

STATIC_IP_NAME=153.148.244.35.bc.googleusercontent.com.
HOSTS=( \
  "demo1-live" \
  "demo1-stage" \
)

ZONE=esploranto-com
DOMAIN=esploranto.com


gcloud dns record-sets transaction start --zone=${ZONE}

for host in "${HOSTS[@]}"
do
  FQDN="${host}.${DOMAIN}."
  echo "Adding DNS record '${FQDN}'..."
  gcloud dns record-sets transaction add "$STATIC_IP_NAME" \
      --name="${FQDN}" --ttl=300 \
      --type=CNAME --zone=${ZONE}
done


gcloud dns record-sets transaction execute --zone=${ZONE}

gcloud dns record-sets list --zone=${ZONE}
