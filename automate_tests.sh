#!/bin/sh

declare -a useCases=("devops")
declare -a scales=("10" "15")

for useCase in "${useCases[@]}"
do
for scale in "${scales[@]}"
do
    echo RUNNING FOR $useCase $scale
    docker compose up -d
    sh generate-data.sh $scale $useCase
    sh benchmark-databases.sh $scale $useCase
    docker compose down

done
done
