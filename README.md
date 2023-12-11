# Run the test
Make sure that you run 
```
docker compose up -d
```
and that you are running 4 services, you can check this with `docker ps`, 4 results should appear. 
Then run 
```
docker compose down
```
to start with the testing then run 

```
bash automate_tests.sh
```

This will pull all dockers, generate the data, generate the queries and run the tests. The results will be shown in the results folder. Feel free to run more scales by editing the `declare -a scales=("10" "20")` variable in the `automate_test.sh` file. 