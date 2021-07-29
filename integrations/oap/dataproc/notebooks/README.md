# Using notebooks to run TPC-DS

## 1. Create a new cluster

To run benchmark on Google Dataproc with OAP feature enabled, you need to upload 
both **[bootstrap_benchmark.sh](../benchmark/bootstrap_benchmark.sh)** and **[bootstrap_oap.sh](../bootstrap_oap.sh)** to bucket, 
add extra bootstrap action to execute **[bootstrap_benchmark.sh](../benchmark/bootstrap_benchmark.sh)** and **[bootstrap_oap.sh](../bootstrap_oap.sh)** when creating a new cluster.

![upload_init_script and install_benchmark.sh](../imgs/upload_scripts_to_bucket.png)

![Add bootstrap action](../imgs/add_scripts.png)

## 2. Generate data

You need to update the following configurations according to your request on **[tpcds_datagen.ipynb](./tpcds_datagen_Dataproc.ipynb)**:
```
val scale = "1"                   // data scale 1GB
val format = "parquet"            // support parquer or orc
val partitionTables = true        // create partitioned table
val storage = "hdfs"
val bucket_name = "/user/livy"
val useDoubleForDecimal = false   // use double format instead of decimal format
```
Then you can use **[tpcds_datagen.ipynb](./tpcds_datagen_Dataproc.ipynb)** to generate data.

## 3. Run TPC-DS power test

There are two notebooks for users to easily run TPC-DS power test with Dataproc spark or Gazella_plugin.
You need to update the following configurations according to your request on **[tpcds_power_test.ipynb](./tpcds_power_test_Dataproc.ipynb)(Dataproc spark)** or **[tpcds_power_test_with_gazelle_plugin.ipynb](./tpcds_power_test_with_gazelle_plugin_Dataproc.ipynb)**(Gazelle_plugin):
```
val scaleFactor = "1"             // data scale 1GB
val iterations = 1                // how many times to run the whole set of queries.
val format = "parquet"            // support parquer or orc
val storage = "hdfs"
val bucket_name = "/user/livy"
val partitionTables = true        // create partition tables
val query_filter = Seq()          // Seq() == all queries
//val query_filter = Seq("q1-v2.4", "q2-v2.4") // run subset of queries
val randomizeQueries = false      // run queries in a random order. Recommended for parallel runs.
```

## 4. Run TPC-DS throughput test

Here are 2 notebooks for users to easily run TPC-DS throughput test with Dataproc Spark or Gazella Plugin.
You need to update the following configurations according to your request on **[tpcds_throughput_test.ipynb](./tpcds_throughput_test_Dataproc.ipynb)(Dataproc spark)** or **[tpcds_throughput_test_with_gazelle_plugin.ipynb](./tpcds_throughput_test_with_gazelle_plugin_Dataproc.ipynb)**(Gazelle_plugin):
```
val stream_num = 2                // how many streams you want to start 
val scaleFactor = "1"             // data scale 1GB
val iterations = 1                // how many times to run the whole set of queries.
val format = "parquet"            // support parquer or or
val storage = "hdfs"
val bucket_name = "/user/livy"
val partitionTables = true        // create partition tables
val query_filter = Seq()          // Seq() == all queries
//val query_filter = Seq("q1-v2.4", "q2-v2.4") // run subset of queries
val randomizeQueries = true       // run queries in a random order. Recommended for parallel runs.
```
