QUESTDB
============
```
SELECT 
  timestamp AS minute, 
  MAX(usage_user)
FROM cpu
WHERE 
  hostname  = 'host_0'
  and  timestamp >= '2023-11-01T00:00:00Z'
  AND timestamp < '2023-11-01T01:00:00Z'
sample by 1m;
```



POSTGRES
===========
```
SELECT date_trunc('minute', time) AS minute, 
  MAX(usage_user)
FROM cpu
WHERE 
  tags_id  = 1
  and  time >= '2023-11-01T00:00:00Z'
  AND time < '2023-11-01T01:00:00Z'
GROUP BY minute
ORDER BY minute ASC;
```


INFLUX :C
=========
```
from(bucket: "benchmark")
  |> range(start: 2023-11-01T00:00:00Z, stop: 2023-11-01T01:00:00Z)
  |> filter(fn: (r) => r["_measurement"] == "cpu" and r["hostname"] == "host_0" and r["_field"] == "usage_user")
  |> aggregateWindow(every: 1m, fn: max, createEmpty: false)
  |> yield(name: "max_usage_user")
```




Complicated query 
============



Postgres
==========
```
SELECT date_trunc('hour', TIME) 
  AS hour, tags_id, avg(usage_user) 
  AS mean_usage_user 
FROM cpu
WHERE TIME >= '2023-11-01T00:00:00Z'
  AND TIME < '2023-11-02T00:00:00Z'
GROUP BY hour, tags_id
ORDER BY hour;
```

QUESTDB
========
```
SELECT 
  timestamp AS hour, 
  avg(usage_user) AS mean_usage_user 
FROM cpu
WHERE timestamp >= '2023-11-01T00:00:00Z'
  AND timestamp < '2023-11-02T00:00:00Z'
SAMPLE BY 1h;
```


FLUX
========
```
from(bucket: "benchmark")
  |> range(start: 2023-11-01T00:00:00Z, stop: 2023-11-02T00:00:00Z)
  |> filter(fn: (r) => r["_measurement"] == "cpu" and r["_field"] == "usage_user")
  |> group(columns: ["hostname"])
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> yield(name: "mean_usage_user")
```