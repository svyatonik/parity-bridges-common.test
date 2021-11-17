#!/bin/bash
. ./prelude.sh

###############################################################################
### Starting Prometheus + Grafana #############################################
###############################################################################

# copy common files requires for dashboard
rm -rf data/dashboards
mkdir -p data/dashboards
cp -rf dashboards/grafana-dashboard.yaml data/dashboards
cp -rf dashboards/grafana-datasource.yaml data/dashboards
cp -rf dashboards/prometheus.yml data/dashboards
cp -rf dashboards/prometheus-targets-complex.yml data/dashboards
cp -rf dashboards/prometheus-targets-standalone.yml data/dashboards

# prepare Rialto-PoA -> Rialto headers relay dashboard
cp -rf dashboards/relay-headers-dashboard.json data/dashboards/relay-eth2sub-dashboard.json
sed -i 's/{SOURCE_NAME}/Ethereum/g' data/dashboards/relay-eth2sub-dashboard.json
sed -i 's/{TARGET_NAME}/Substrate/g' data/dashboards/relay-eth2sub-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-eth2sub/g' data/dashboards/relay-eth2sub-dashboard.json
sed -i 's/{BRIDGE_NAME}/eth2sub/g' data/dashboards/relay-eth2sub-dashboard.json

# prepare Rialto -> Rialto-PoA headers relay dashboard
cp -rf dashboards/relay-headers-dashboard.json data/dashboards/relay-sub2eth-dashboard.json
sed -i 's/{SOURCE_NAME}/Substrate/g' data/dashboards/relay-sub2eth-dashboard.json
sed -i 's/{TARGET_NAME}/Ethereum/g' data/dashboards/relay-sub2eth-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-sub2eth/g' data/dashboards/relay-sub2eth-dashboard.json
sed -i 's/{BRIDGE_NAME}/sub2eth/g' data/dashboards/relay-sub2eth-dashboard.json

# prepare Rialto-PoA -> Rialto exchange relay dashboard
cp -rf dashboards/relay-exchange-dashboard.json data/dashboards/relay-eth2sub-exchange-dashboard.json
sed -i 's/{SOURCE_NAME}/Ethereum/g' data/dashboards/relay-eth2sub-exchange-dashboard.json
sed -i 's/{TARGET_NAME}/Substrate/g' data/dashboards/relay-eth2sub-exchange-dashboard.json
sed -i 's/{BRIDGE_ID}/eth2sub-exchange/g' data/dashboards/relay-eth2sub-exchange-dashboard.json

# prepare Rialto -> Millau headers relay dashboard
cp -rf dashboards/relay-headers-dashboard.json data/dashboards/relay-rialto2millau-dashboard.json
sed -i 's/{SOURCE_NAME}/Rialto/g' data/dashboards/relay-rialto2millau-dashboard.json
sed -i 's/{TARGET_NAME}/Millau/g' data/dashboards/relay-rialto2millau-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-rialto2millau/g' data/dashboards/relay-rialto2millau-dashboard.json
sed -i 's/{JOB_NAME}/rialto2millau_relay/g' data/dashboards/relay-rialto2millau-dashboard.json

# prepare Millau -> Rialto headers relay dashboard
cp -rf dashboards/relay-headers-dashboard.json data/dashboards/relay-millau2rialto-dashboard.json
sed -i 's/{SOURCE_NAME}/Millau/g' data/dashboards/relay-millau2rialto-dashboard.json
sed -i 's/{TARGET_NAME}/Rialto/g' data/dashboards/relay-millau2rialto-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-millau2rialto/g' data/dashboards/relay-millau2rialto-dashboard.json
sed -i 's/{JOB_NAME}/millau2rialto_relay/g' data/dashboards/relay-millau2rialto-dashboard.json

# prepare Millau -> Rialto messages relay dashboard (lane 00000000)
cp -rf dashboards/relay-messages-dashboard.json data/dashboards/relay-millau2rialto-messages-00000000-dashboard.json
sed -i 's/{SOURCE_NAME}/Millau/g' data/dashboards/relay-millau2rialto-messages-00000000-dashboard.json
sed -i 's/{TARGET_NAME}/Rialto/g' data/dashboards/relay-millau2rialto-messages-00000000-dashboard.json
sed -i 's/{LANE_ID}/00000000/g' data/dashboards/relay-millau2rialto-messages-00000000-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-millau2rialto-messages-00000000/g' data/dashboards/relay-millau2rialto-messages-00000000-dashboard.json
sed -i 's/{JOB_NAME}/millau2rialto_00000000_lane_relay/g' data/dashboards/relay-millau2rialto-messages-00000000-dashboard.json

# prepare Rialto -> Millau messages relay dashboard (lane 00000000)
cp -rf dashboards/relay-messages-dashboard.json data/dashboards/relay-rialto2millau-messages-00000000-dashboard.json
sed -i 's/{SOURCE_NAME}/Rialto/g' data/dashboards/relay-rialto2millau-messages-00000000-dashboard.json
sed -i 's/{TARGET_NAME}/Millau/g' data/dashboards/relay-rialto2millau-messages-00000000-dashboard.json
sed -i 's/{LANE_ID}/00000000/g' data/dashboards/relay-rialto2millau-messages-00000000-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-rialto2millau-messages-00000000/g' data/dashboards/relay-rialto2millau-messages-00000000-dashboard.json
sed -i 's/{JOB_NAME}/rialto2millau_00000000_lane_relay/g' data/dashboards/relay-rialto2millau-messages-00000000-dashboard.json

# prepare Millau -> Rialto messages relay dashboard (lane 00000001)
cp -rf dashboards/relay-messages-dashboard.json data/dashboards/relay-millau2rialto-messages-00000001-dashboard.json
sed -i 's/{SOURCE_NAME}/Millau/g' data/dashboards/relay-millau2rialto-messages-00000001-dashboard.json
sed -i 's/{TARGET_NAME}/Rialto/g' data/dashboards/relay-millau2rialto-messages-00000001-dashboard.json
sed -i 's/{LANE_ID}/00000001/g' data/dashboards/relay-millau2rialto-messages-00000001-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-millau2rialto-messages-00000001/g' data/dashboards/relay-millau2rialto-messages-00000001-dashboard.json
sed -i 's/{JOB_NAME}/millau2rialto_00000001_lane_relay/g' data/dashboards/relay-millau2rialto-messages-00000001-dashboard.json

# prepare Rialto -> Millau messages relay dashboard (lane 00000001)
cp -rf dashboards/relay-messages-dashboard.json data/dashboards/relay-rialto2millau-messages-00000001-dashboard.json
sed -i 's/{SOURCE_NAME}/Rialto/g' data/dashboards/relay-rialto2millau-messages-00000001-dashboard.json
sed -i 's/{TARGET_NAME}/Millau/g' data/dashboards/relay-rialto2millau-messages-00000001-dashboard.json
sed -i 's/{LANE_ID}/00000001/g' data/dashboards/relay-rialto2millau-messages-00000001-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-rialto2millau-messages-00000001/g' data/dashboards/relay-rialto2millau-messages-00000001-dashboard.json
sed -i 's/{JOB_NAME}/rialto2millau_00000001_lane_relay/g' data/dashboards/relay-rialto2millau-messages-00000001-dashboard.json

# prepare Millau -> Rialto messages relay dashboard (lane 00000002)
cp -rf dashboards/relay-messages-dashboard.json data/dashboards/relay-millau2rialto-messages-00000002-dashboard.json
sed -i 's/{SOURCE_NAME}/Millau/g' data/dashboards/relay-millau2rialto-messages-00000002-dashboard.json
sed -i 's/{TARGET_NAME}/Rialto/g' data/dashboards/relay-millau2rialto-messages-00000002-dashboard.json
sed -i 's/{LANE_ID}/00000002/g' data/dashboards/relay-millau2rialto-messages-00000002-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-millau2rialto-messages-00000002/g' data/dashboards/relay-millau2rialto-messages-00000002-dashboard.json
sed -i 's/{JOB_NAME}/millau2rialto_00000002_lane_relay/g' data/dashboards/relay-millau2rialto-messages-00000002-dashboard.json

# prepare Rialto -> Millau messages relay dashboard (lane 00000002)
cp -rf dashboards/relay-messages-dashboard.json data/dashboards/relay-rialto2millau-messages-00000002-dashboard.json
sed -i 's/{SOURCE_NAME}/Rialto/g' data/dashboards/relay-rialto2millau-messages-00000002-dashboard.json
sed -i 's/{TARGET_NAME}/Millau/g' data/dashboards/relay-rialto2millau-messages-00000002-dashboard.json
sed -i 's/{LANE_ID}/00000002/g' data/dashboards/relay-rialto2millau-messages-00000002-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-rialto2millau-messages-00000002/g' data/dashboards/relay-rialto2millau-messages-00000002-dashboard.json
sed -i 's/{JOB_NAME}/rialto2millau_00000002_lane_relay/g' data/dashboards/relay-rialto2millau-messages-00000002-dashboard.json

# prepare Westend -> Millau headers relay dashboard
cp -rf dashboards/relay-headers-dashboard.json data/dashboards/relay-westend2millau-dashboard.json
sed -i 's/{SOURCE_NAME}/Westend/g' data/dashboards/relay-westend2millau-dashboard.json
sed -i 's/{TARGET_NAME}/Millau/g' data/dashboards/relay-westend2millau-dashboard.json
sed -i 's/{BRIDGE_ID}/relay-westend2millau/g' data/dashboards/relay-westend2millau-dashboard.json
sed -i 's/{BRIDGE_NAME}/westend2millau/g' data/dashboards/relay-westend2millau-dashboard.json

# prepare maintenance dashboard
cp -rf dashboards/maintenance-dashboard.json data/dashboards/maintenance-dashboard.json

# run prometheus (http://127.0.0.1:9090/)
if [ -z "$USE_COMPLEX_MILLAU_RIALTO_RELAY" ]; then
PROMETHEUS_TARGETS=prometheus-targets-standalone.yml
else
PROMETHEUS_TARGETS=prometheus-targets-complex.yml
fi

docker container rm relay-prometheus | true
docker run \
	--name=relay-prometheus \
	--network=host \
	-v `realpath data/dashboards/prometheus.yml`:/etc/prometheus/prometheus.yml \
	-v `realpath data/dashboards/$PROMETHEUS_TARGETS`:/etc/prometheus/prometheus-targets.yml \
	prom/prometheus \
	--config.file /etc/prometheus/prometheus.yml&

# run grafana (http://127.0.0.1:3000/ + admin/admin)
docker container rm relay-grafana | true
docker run \
	--name=relay-grafana \
	--network=host \
	-v `realpath data/dashboards/grafana-datasource.yaml`:/etc/grafana/provisioning/datasources/grafana-datasource.yaml \
	-v `realpath data/dashboards/grafana-dashboard.yaml`:/etc/grafana/provisioning/dashboards/grafana-dashboard.yaml \
	-v `realpath data/dashboards/maintenance-dashboard.json`:/etc/grafana/provisioning/dashboards/maintenance-dashboard.json \
	-v `realpath data/dashboards/relay-eth2sub-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-eth2sub-dashboard.json \
	-v `realpath data/dashboards/relay-sub2eth-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-sub2eth-dashboard.json \
	-v `realpath data/dashboards/relay-eth2sub-exchange-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-eth2sub-exchange-dashboard.json \
	-v `realpath data/dashboards/relay-rialto2millau-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-rialto2millau-dashboard.json \
	-v `realpath data/dashboards/relay-millau2rialto-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-millau2rialto-dashboard.json \
	-v `realpath data/dashboards/relay-westend2millau-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-westend2millau-dashboard.json \
	-v `realpath data/dashboards/relay-millau2rialto-messages-00000000-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-millau2rialto-messages-00000000-dashboard.json \
	-v `realpath data/dashboards/relay-rialto2millau-messages-00000000-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-rialto2millau-messages-00000000-dashboard.json \
	-v `realpath data/dashboards/relay-millau2rialto-messages-00000001-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-millau2rialto-messages-00000001-dashboard.json \
	-v `realpath data/dashboards/relay-rialto2millau-messages-00000001-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-rialto2millau-messages-00000001-dashboard.json \
	-v `realpath data/dashboards/relay-millau2rialto-messages-00000002-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-millau2rialto-messages-00000002-dashboard.json \
	-v `realpath data/dashboards/relay-rialto2millau-messages-00000002-dashboard.json`:/etc/grafana/provisioning/dashboards/relay-rialto2millau-messages-00000002-dashboard.json \
	grafana/grafana&
