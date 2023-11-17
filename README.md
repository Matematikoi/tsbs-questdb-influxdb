# Build the dockers
You can the docker in mac and linux with 
```sh
sh build-docker.sh
```

# Generate data

You can generate the data with the following command for scale 100
```sh
sh generate-data 100
```




# Run docker for questDB
```
docker run -p 9000:9000  \
      -p 8812:8812 \
      -p 9009:9009 \
      questdb/questdb
```

# Generate Data

```
./tsbs_generate_data --use-case="cpu-only" --seed=123 --scale=4000 --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-15T00:00:00Z" --log-interval="10s" --format="questdb"  > /tmp/questdb_data
```
# Load the data

```
./tsbs_load_questdb --file=/tmp/questdb_data --ilp-bind-to=localhost:9009 --workers=5
```

# Generate queries
```
./tsbs_generate_queries --use-case="cpu-only" --seed=123 --scale=4000 --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-04T00:00:01Z" --queries=1000 --query-type="groupby-orderby-limit" --format="questdb"  > /tmp/questdb_query
```

# Run queries
```
./tsbs_run_queries_questdb --file=/tmp/questdb_query --urls=http://localhost:9000 --workers=10
```

# Pa correr influx
```
docker run --rm -p 8086:8086 \
      -v $PWD/data:/var/lib/influxdb2 \
      -v $PWD/config:/etc/influxdb2 \
      -e DOCKER_INFLUXDB_INIT_MODE=setup \
      -e DOCKER_INFLUXDB_INIT_USERNAME=gabriel \
      -e DOCKER_INFLUXDB_INIT_PASSWORD=gabrielmelapela \
      -e DOCKER_INFLUXDB_INIT_ORG=ulb \
      -e DOCKER_INFLUXDB_INIT_BUCKET=benchmark \
      --name influxdb \
      influxdb:2.7
```

./tsbs_generate_data --use-case="cpu-only" --seed=123 --scale=1000 --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-15T00:00:00Z" --log-interval="10s" --format="influx"  > /tmp/influx_data

./tsbs_load_influx --db-name=benchmark --file=./influx_data --urls=http://localhost:8086 --auth-token="swQNCZnGMhxqmrzK7CYGxTPE_mTblQXqsS296A7pqdSFp755tGZY4Dn8NYTU4N_NPz1vSkHnECs5lu1acEn0nQ==" --workers=10

./tsbs_generate_queries --use-case="cpu-only" --seed=123 --scale=4000 --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-04T00:00:01Z" --queries=1000 --query-type="groupby-orderby-limit" --format="influx" > ./influx_query

./tsbs_run_queries_influx --db-name=benchmark --file=/tmp/influx_query --urls=http://localhost:8086 --auth-token="swQNCZnGMhxqmrzK7CYGxTPE_mTblQXqsS296A7pqdSFp755tGZY4Dn8NYTU4N_NPz1vSkHnECs5lu1acEn0nQ==" --workers=10


# Docker golang

docker build -t tsbs:0.1 .

docker run --name golang -d tsbs:0.1


docker exec benchmark-golang-1 ./tsbs_load_influx --db-name=benchmark --file=./data/influx_data.txt --urls=http://localhost:8086 --auth-token="lGeJ4LLYpUj6pSFSHF8ICWDgLR7Ut8KptNtsPKcN9HeCTroszL9YH4tr3YpgA3PiKTQvivxrWlkmv2K7oq_FXQ==" --workers=10


docker cp data benchmark-golang-1:/
docker exec benchmark-golang-1 ./tsbs_load_questdb --file=/data/questdb_data.txt --ilp-bind-to=localhost:9009 --workers=5



./tsbs_load_questdb --file=./../../data/questdb_data.txt --ilp-bind-to=localhost:9009 --workers=5
