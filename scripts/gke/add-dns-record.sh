#!/bin/bash

usage () {
  echo "Usage: `basename $0`  <zone> <domain>"
  echo "  <zone>   Google Cloud DNS zone name)"
  echo "  <domain> Top level domain name"
}

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

ZONE=esploranto-com
DOMAIN=esploranto.com

STAGE_IP=$(kubectl get svc | grep "apache-stage" | awk '{print $4}')
STAGE_SERVICE=$(kubectl get svc | grep "apache-stage" | awk '{print $1}')
STAGE_FQDN="${STAGE_SERVICE}.${DOMAIN}."

LIVE_IP=$(kubectl get svc | grep "apache-live" | awk '{print $4}')
LIVE_SERVICE=$(kubectl get svc | grep "apache-live" | awk '{print $1}')
LIVE_FQDN="${LIVE_SERVICE}.${DOMAIN}."

echo "Creating Google Cloud DNS record set for zone: ${ZONE}"
HEADER="%-10s\t%s\n"
printf $HEADER "IP" "FQDN"
printf $HEADER "${STAGE_IP}" "${STAGE_FQDN}"
printf $HEADER "${LIVE_IP}" "${LIVE_FQDN}"

if [ -e transaction.yaml ]; then
  rm tranaction.yaml
fi

gcloud dns record-sets transaction start --zone=${ZONE}

gcloud dns record-sets transaction add "$STAGE_IP" \
      --name="${STAGE_FQDN}" --ttl=300 \
      --type=A --zone=${ZONE}

gcloud dns record-sets transaction add "$LIVE_IP" \
      --name="${LIVE_FQDN}" --ttl=300 \
      --type=A --zone=${ZONE}

gcloud dns record-sets transaction execute --zone=${ZONE}

gcloud dns record-sets list --zone=${ZONE}
