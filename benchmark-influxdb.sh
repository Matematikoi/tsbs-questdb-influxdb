#!/bin/sh


docker run --name golang -p 8086:8087 -d tsbs:0.1

influx auth create --all-access > foo.txt
cat foo.txt | cut -f4 -d$'\t' foo.txt| tail -n 1