#!/bin/sh

# $1 is the scale, an int
# $2 is the use case cpu-only devops iot
docker compose down
docker compose up -d

sleep 3
docker cp data benchmark-golang-1:/


influx_pwd=$(docker exec -it benchmark-influxdb-1 influx auth create --all-access --org ulb | cut -f4 -d$'\t' | tail -n 1)
echo LOADING DATA TO INFLUXDB
docker exec benchmark-golang-1 /tsbs_load_influx --db-name=benchmark --file=/data/influxdb_data.txt --urls=http://influxdb:8086 --auth-token=${influx_pwd} --workers=5 > results/loading_times_influxdb_$1_$2.txt
echo BENCHMARK INFLUXDB
docker exec benchmark-golang-1 ./tsbs_run_queries_influx --db-name=benchmark --file=/data/influxdb_query.txt --urls=http://influxdb:8086 --auth-token=${influx_pwd} --workers=5 > results/query_times_influxdb_$1_$2.txt


echo LOADING DATA TO QUESTDB
docker exec benchmark-golang-1 ./tsbs_load_questdb --file=/data/questdb_data.txt --ilp-bind-to=questdb:9009 --workers=5 > results/loading_times_questdb_$1_$2.txt
echo BENCHMARK QUESTDB
docker exec benchmark-golang-1 ./tsbs_run_queries_questdb --file=/data/questdb_query.txt --url=http://questdb:9000 --workers=5 > results/query_times_questdb_$1_$2.txt



docker kill benchmark-golang-1
docker rm benchmark-golang-1
