# Run benchmark on Kubernetes

Firstly, need launch one Spark client pod. Refer to [Start the Client](../README.md#start-the-client).


## Run TPCDS

### Generate TPCDS data
Go to folder benchmark, open the tpcds_datagen.scala and modify the below variables based on integration environments.  
```
// Modify parameters based on integration environments
val scale = "1"
val format = "parquet"
val storage_path = "s3a://aws-emr-resources-348941870272-us-east-2/eks/"
// "true" means use double type instead of decimal
val useDoubleForDecimal = false
// "true" means generate tables with partions
val partitionTables = true
```

Then execute the following command.
``` 
cat tpcds_datagen.scala | sh ../spark/spark-shell-client.sh --jars /opt/home/tools/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar
``` 

### Run TPCDS benchmark

