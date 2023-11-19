#!/bin/sh

declare -a useCases=("cpu-only" "iot" "devops")
declare -a scales=("1" "2" "4" "8" "16" "32" "64" "128")

for useCase in "${useCases[@]}"
do
for scale in "${scales[@]}"
do
    echo RUNNING FOR $useCase $scale
    sh generate-data.sh $scale $useCase
    sh benchmark-databases.sh $scale $useCase

done
done
