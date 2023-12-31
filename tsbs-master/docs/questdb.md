# TSBS Supplemental Guide: QuestDB

QuestDB is a high-performance open-source time series database with SQL as a
query language with time-oriented extensions. QuestDB implements PostgreSQL wire
protocol, REST API, and supports ingestion using InfluxDB Line Protocol over TCP.

This guide explains how the data for TSBS is generated along with additional
flags available when using the data importer (`tsbs_load_questdb`).

**This should be read _after_ the main README.**

## Data format

Data generated by `tsbs_generate_data` is in InfluxDB line protocol format where each
reading is composed of the following:

- the table name followed by a comma
- several comma-separated items of tags in the format `<label>=<value>` followed
  by a space
- several comma-separated items of fields in the format `<label>=<value>`
  followed by a space
- a timestamp for the record
- a newline character `\n`

An example reading from the Dev Ops use case looks like the following:

```text
cpu,hostname=host_0,region=eu-central-1,datacenter=eu-central-1a,rack=6,os=Ubuntu15.10,arch=x86,team=SF,service=19,service_version=1,service_environment=test usage_user=58i,usage_system=2i,usage_idle=24i,usage_nice=61i,usage_iowait=22i,usage_irq=63i,usage_softirq=6i,usage_steal=44i,usage_guest=80i,usage_guest_nice=38i 1451606400000000000
```

## `tsbs_load_questdb` additional flags

**`--ilp-bind-to`** (type: `string`, default `127.0.0.1:9009`)

QuestDB InfluxDB line protocol TCP port in the format `<ip>:<port>`

**`--url`** (type: `string`, default: `http://localhost:9000/`)

QuestDB REST end point.

**`-help`**

Prints available flags and their defaults:

```bash
tsbs_load_questdb --help
```

## How to run the test (Linux example)

Firstly, install and build the benchmark suite

### Set up TSBS

Clone the TSBS repository and build it:

```bash
git clone git@github.com:questdb/tsbs.git
cd ./tsbs/
make
cd ./bin/
```

### Generating data

Data is generated using the `questdb` format. To generate a small dataset for
quick benchmarks:

```bash
./tsbs_generate_data \
  --use-case="cpu-only" --seed=123 --scale=4000 \
  --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-01T01:00:00Z" \
  --log-interval="10s" --format="questdb" > /tmp/data
```

To generate a full data set for more intensive benchmarks:

```bash
./tsbs_generate_data \
  --use-case="cpu-only" --seed=123 --scale=4000 \
  --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-02T00:00:00Z" \
  --log-interval="10s" --format="questdb" > /tmp/data
```

### Running the benchmark tool

Generated data can be loaded directly using the tool:

```bash
./tsbs_load_questdb --file /tmp/data --workers 4
```

### Query benchmarks for Dev Ops data set (single-groupby-5-8-1 type)

Queries are generated using the `questdb` format.

**single-groupby-5-8-1:**

The dataset used to run the queries is created with the following commands for
`single-groupby-5-8-1`:

```bash
cd ~/tmp/go/src/github.com/questdb/

./tsbs_generate_queries \
  --use-case="cpu-only" --seed=123 --scale=4000 \
  --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-02T00:00:01Z" \
  --queries=1000 --query-type="single-groupby-5-8-1" \
  --format="questdb" > /tmp/queries_questdb

./tsbs_run_queries_questdb --file /tmp/queries_questdb --print-interval 500
```

### Query benchmarks for Dev Ops data set (high-cpu-1 use case)

Queries are generated using the `questdb` format.

**high-cpu-1:**

The dataset used to run the queries is created with the following commands for
`high-cpu-1`:

```bash
cd ~/tmp/go/src/github.com/questdb/

./tsbs_generate_queries \
  --use-case="cpu-only" --seed=123 --scale=4000 \
  --timestamp-start="2016-01-01T00:00:00Z" --timestamp-end="2016-01-02T00:00:01Z" \
  --queries=1000 --query-type="high-cpu-1" --format="questdb" > /tmp/queries_questdb

./tsbs_run_queries_questdb --file /tmp/queries_questdb --print-interval 500
```

### TLS and authentication support

The ingestion benchmark tool supports InfluxDB Line Protocol authentication as
well as TLS encryption:
```bash
./tsbs_load_questdb --file /tmp/data --workers 4 \
  --tls \
  --auth-id "my_user" \
  --auth-token "GwBXoGG5c6NoUTLXnzMxw_uNiVa8PKobzx5EiuylMW0"
```

The query benchmark tool also supports basic HTTP authentication and TLS encryption:
```bash
./tsbs_run_queries_questdb --file /tmp/queries_questdb \
  --url "https://localhost:9000" \
  --username user \
  --password quest
```
