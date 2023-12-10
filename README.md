# Run the test

We have connected multiple dockers and services into only one command. As long as you have docker and are able to run docker compose without sudo permission just run 

```
sh automate_tests.sh
```

This will pull all dockers, generate the data, generate the queries and run the tests. The results will be shown in the results folder. Feel free to run more scales by editing the `declare -a scales=("10" "20")` variable in the `automate_test.sh` file. 