#!/bin/sh

rm data/*txt
docker run --name golang -d tsbs:0.1
sleep 3
echo GENERATING QUESTDB DATA
docker exec golang ./tsbs_generate_data --use-case="cpu-only" --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="questdb"  > ./data/questdb_data.txt
echo GENERATING INFLUXDB DATA
docker exec golang ./tsbs_generate_data --use-case="cpu-only" --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="influx"  > ./data/influx_data.txt

docker kill golang
docker rm golang

