#!/bash/sh

docker compose down
docker compose up -d

sleep 3

echo GENERATING QUESTDB DATA
docker exec golang ./tsbs_generate_data --use-case=cpu-only --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="questdb"  > ./data/questdb_data.txt
echo GENERATING INFLUXDB DATA
docker exec golang ./tsbs_generate_data --use-case=cpu-only --seed=123 --scale=$1 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="influx"  > ./data/influxdb_data.txt
echo GENERATING POSTGRES DATA 
docker exec golang ./tsbs_generate_data --use-case=cpu-only --seed=123 --scale=10 --timestamp-start="2023-11-01T00:00:00Z" --timestamp-end="2023-11-15T00:00:00Z" --log-interval="10s" --format="timescaledb"  > ./data/postgres_data.txt

docker cp data golang:/

echo LOADING DATA TO INFLUX
influx_pwd=$(docker exec -it benchmark-influxdb-1 influx auth create --all-access --org ulb | cut -f4 -d$'\t' | tail -n 1)
docker exec golang /tsbs_load_influx --db-name=benchmark --file=/data/influxdb_data.txt --urls=http://influxdb:8086 --auth-token=${influx_pwd} --workers=5
echo LOADING DATA TO QUESTDB
docker exec golang ./tsbs_load_questdb --file=/data/questdb_data.txt --ilp-bind-to=questdb:9009 --workers=5
echo LOADING DATA TO POSTGRES
docker exec golang ./tsbs_load_timescaledb --host=postgres --use-hypertable=false --file=/data/postgres_data.txt --pass=estaesunamalacontrasena --workers=5

# for questdb http://localhost:9000 in browser
# for influxdb http://localhost:8086 in browser
#   the user is gabriel
#   the pwd is estaesunamalacontrasena
# for postgres the user is postgres, the pwd is estaesunamalacontrasena
# the host is localhost and the port is 5433 (NOT 5432) the database is benchmark
