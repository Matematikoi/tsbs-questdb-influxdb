#!/bin/sh


cd tsbs-master
docker build -t tsbs:0.1 .
cd ..

cd influx-docker
docker build -t influxdb:2.7 .
