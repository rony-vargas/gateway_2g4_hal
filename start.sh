#!/usr/bin/env bash
TAG_KEY="EUI"
TTN_EUI=$(util_chip_id/chip_id | grep "concentrator EUI" | awk -F' ' '{$1 = substr($4, 3,16); printf $1}')


echo "Gateway EUI: $TTN_EUI"

ID=$(curl -sX GET "https://api.balena-cloud.com/v5/device?\$filter=uuid%20eq%20'$BALENA_DEVICE_UUID'" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" | \
jq ".d | .[0] | .id")

TAG=$(curl -sX POST \
"https://api.balena-cloud.com/v5/device_tag" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" \
--data "{ \"device\": \"$ID\", \"tag_key\": \"$TAG_KEY\", \"value\": \"$TTN_EUI\" }" > /dev/null)

sed -i "s/"auto"/$TTN_EUI/g" packet_forwarder/global_conf.json
sed -i "s/"localhost"/eu1.cloud.thethings.network/g" packet_forwarder/global_conf.json

cd packet_forwarder
./lora_pkt_fwd