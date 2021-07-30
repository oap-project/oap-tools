# Gazelle on GCP Dataproc 2.0

## 1. Creating a cluster on Dataproc

### 1.1 Uploading initialization actions

Upload the initialization actions scripts to Cloud Storage Buckets. 

**[bootstrap_oap.sh](../integrations/oap/dataproc/bootstrap_oap.sh)** is to help install OAP packages with conda.

**[bootstrap_benchmark.sh](../integrations/oap/dataproc/benchmark/bootstrap_benchmark.sh)** is to help install necessary tools for TPC-DS, TPC-H and HiBench on Dataproc clusters.
    
1). Download **[bootstrap_oap.sh](../integrations/oap/dataproc/bootstrap_oap.sh)** and **[bootstrap_benchmark.sh](../integrations/oap/dataproc/benchmark/bootstrap_benchmark.sh)** to a local folder.

2). Upload these scripts to Bucket.

![upload_init_script and install_benchmark.sh](../integrations/oap/dataproc/imgs/upload_scripts_to_bucket.png)


### 1.2 Create a new cluster with initialization actions

To create a new cluster with initialization actions, follow the steps below:

1). Click the  **CREATE CLUSTER** to create and custom your cluster.

2). **Set up cluster:** choose cluster type and Dataproc image version `2.0-centos8`,  enable component gateway.
![Enable_component_gateway](../integrations/oap/dataproc/imgs/component_gateway.png)

3). **Configure nodes:** choose the instance type and other configurations of nodes.

4). **Customize cluster:** add initialization actions as below;
![Add bootstrap action](../integrations/oap/dataproc/imgs/add_scripts.png)

5). **Manage security:** define the permissions and other security configurations;

6). Click **Create**. 


## 2. Run TPC-DS with notebooks

### 2.1 Generate data

You need to update the following configurations according to your request on **[tpcds_datagen.ipynb](../integrations/oap/dataproc/notebooks/tpcds_datagen_Dataproc.ipynb)**:
```
val scale = "1"                   // data scale 1GB
val format = "parquet"            // support parquet or orc file format
val partitionTables = true        // create partitioned table
val storage = "gs"                // support Google Cloud Storage buckets -- "gs", or HDFS -- "hdfs"
var bucket_name = "oap-dev"       // Please change to your bucket name 
val useDoubleForDecimal = false   // use double format instead of decimal format
```
Then you can use **[tpcds_datagen.ipynb](../integrations/oap/dataproc/notebooks/tpcds_datagen_Dataproc.ipynb)** to generate data.

### 2.2 Run TPC-DS power test

Here are 2 notebooks for you to easily run TPC-DS power test with Dataproc Spark or Gazella Plugin.

Update the following configuration according to your request on **[tpcds_power_test.ipynb](../integrations/oap/dataproc/notebooks/tpcds_power_test_Dataproc.ipynb)(Dataproc spark)** or **[tpcds_power_test_with_gazelle_plugin.ipynb](../integrations/oap/dataproc/notebooks/tpcds_power_test_with_gazelle_plugin_Dataproc.ipynb)**(Gazelle_plugin):

```
val scaleFactor = "1"             // data scale 1GB
val iterations = 1                // how many times to run the whole set of queries.
val format = "parquet"            // support parquet or orc file format
val storage = "gs"                // support Google Cloud Storage buckets -- "gs", or HDFS -- "hdfs"
var bucket_name = "oap-dev"       // Please change to your bucket name 
val partitionTables = true        // create partition tables
val query_filter = Seq()          // Seq() == all queries
//val query_filter = Seq("q1-v2.4", "q2-v2.4") // run subset of queries
val randomizeQueries = false      // run queries in a random order. Recommended for parallel runs.
```
