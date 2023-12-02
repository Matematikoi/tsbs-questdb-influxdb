#!/bin/sh

# $1 is the scale, an int
# $2 is the use case cpu-only devops

rm data/*txt

sleep 3
echo GENERATING QUESTDB DATA
docker exec golang ./tsbs_generate_data --use-case=$2 --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="questdb"  > ./data/questdb_data.txt
echo GENERATING INFLUXDB DATA
docker exec golang ./tsbs_generate_data --use-case=$2 --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="influx"  > ./data/influxdb_data.txt
echo GENERATING TIMESCALE DATA 
docker exec golang ./tsbs_generate_data --use-case=$2 --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="timescaledb"  > ./data/timescale_data.txt



echo GENERATE QUERIES
# not including  "cpu-max-all-32-24" because it has problems for lower scales
declare -a query_types=("groupby-orderby-limit" "high-cpu-1" "single-groupby-1-8-1" "single-groupby-5-1-12" "cpu-max-all-1" "double-groupby-all" "single-groupby-5-8-1""high-cpu-all" "cpu-max-all-8" "double-groupby-1" "double-groupby-5" "lastpoint" "single-groupby-1-1-1" "single-groupby-1-1-12" "single-groupby-5-1-1")

for query_type in "${query_types[@]}"
do
    echo GENERATING QUERY TYPE $query_type
    docker exec golang ./tsbs_generate_queries --use-case=$2 --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --queries=100 --query-type=$query_type --format="questdb"  > ./data/questdb_query_$query_type.txt
    docker exec golang ./tsbs_generate_queries --use-case=$2 --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --queries=100 --query-type=$query_type --format="influx"  > ./data/influxdb_query_$query_type.txt
    docker exec golang ./tsbs_generate_queries --use-case=$2 --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --queries=100 --query-type=$query_type --format="timescaledb"  > ./data/timescale_query_$query_type.txt
done
