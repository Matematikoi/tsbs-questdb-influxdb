#!/bin/sh

# $1 is the scale, an int
# $2 is the use case cpu-only devops iot

declare -a query_types=("groupby-orderby-limit" "high-cpu-1" "single-groupby-1-8-1" "single-groupby-5-1-12" "cpu-max-all-1" "double-groupby-all" "single-groupby-5-8-1""high-cpu-all" "cpu-max-all-8" "double-groupby-1" "double-groupby-5" "lastpoint" "single-groupby-1-1-1" "single-groupby-1-1-12" "single-groupby-5-1-1")
docker compose down
docker compose up -d
sleep 3


echo LOADING DATA TO INFLUXDB
influx_pwd=$(docker exec -it benchmark-influxdb-1 influx auth create --all-access --org ulb | cut -f4 -d$'\t' | tail -n 1)
docker exec golang /tsbs_load_influx --db-name=benchmark --file=/data/influxdb_data.txt --urls=http://influxdb:8086 --auth-token=${influx_pwd} --workers=5 > results/loading_times_influxdb_$1_$2.txt
echo BENCHMARK INFLUXDB
for query_type in "${query_types[@]}"
do
    docker exec golang ./tsbs_run_queries_influx --db-name=benchmark --file=/data/influxdb_query_$query_type.txt --urls=http://influxdb:8086 --auth-token=${influx_pwd} --workers=5 > results/query_times_influxdb_$1_$2_$query_type.txt
done


docker compose down
docker compose up -d
sleep 3


echo LOADING DATA TO QUESTDB
docker exec golang ./tsbs_load_questdb --file=/data/questdb_data.txt --ilp-bind-to=questdb:9009 --workers=5 > results/loading_times_questdb_$1_$2.txt
echo BENCHMARK QUESTDB
for query_type in "${query_types[@]}"
do
    docker exec golang ./tsbs_run_queries_questdb --file=./data/questdb_query_$query_type.txt --url=http://questdb:9000 --workers=5 > results/query_times_questdb_$1_$2_$query_type.txt
done


docker compose down
docker compose up -d
sleep 3

echo LOADING DATA TO TIMESCALE
docker exec golang ./tsbs_load_timescaledb --port=5432 --host=timescaledb --file=/data/timescale_data.txt --pass=estaesunamalacontrasena --workers=5 > results/loading_times_timescale_$1_$2.txt
echo FINISH LOADING
for query_type in "${query_types[@]}"
do
    docker exec golang ./tsbs_run_queries_timescaledb --port=5432 --hosts="timescaledb" --file=./data/timescale_query_$query_type.txt --pass=estaesunamalacontrasena --workers=5 > results/query_times_timescale_$1_$2_$query_type.txt
done
