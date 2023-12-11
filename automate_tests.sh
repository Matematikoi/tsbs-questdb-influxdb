#!/bash/sh

declare -a useCases=("devops")
declare -a scales=("10" "20")

for useCase in "${useCases[@]}"
do
for scale in "${scales[@]}"
do
    echo RUNNING FOR $useCase $scale
    docker-compose up -d
    bash generate-data.sh $scale $useCase
    bash benchmark-databases.sh $scale $useCase
    docker-compose down
done
done
