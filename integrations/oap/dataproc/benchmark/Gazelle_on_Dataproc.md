# Gazelle on GCP Dataproc 2.0

## 1. Creating a cluster on Dataproc 2.0

### 1.1 Uploading initialization actions

Upload the initialization actions scripts to Cloud Storage bucket. 
**[bootstrap_oap.sh](../bootstrap_oap.sh)** is to help conda install OAP packages and
**[bootstrap_benchmark.sh](./bootstrap_benchmark.sh)** is to help install necessary tools for TPC-DS, TPC-H and HIBench on Dataproc clusters.
    
1). Download **[bootstrap_oap.sh](../bootstrap_oap.sh)** and **[bootstrap_benchmark.sh](./bootstrap_benchmark.sh)** to a local folder.

2). Upload these scripts to bucket.

![upload_init_script and install_benchmark.sh](../imgs/upload_scripts_to_bucket.png)


### 1.2 Create a new cluster with initialization actions

To create a new cluster with initialization actions, follow the steps below:

1). Click the  **CREATE CLUSTER** to create and custom your cluster.

2). **Set up cluster:** choose cluster type and Dataproc image version `2.0-centos8`, enable component gateway, and add Jupyter Notebook, ZooKeeper.

![Enable_component_gateway](../imgs/component_gateway.png)

3). **Configure nodes:** choose the instance type and other configurations of nodes.

4). **Customize cluster:** add initialization actions as below;

5). **Manage security:** define the permissions and other security configurations;

6). Click **EQUIVALENT COMMAND LINE**, then click **RUN IN CLOUD SHELL** to add argument ` --initialization-action-timeout 60m ` to your command,
which sets timeout period for the initialization action to 60 minutes. You can also set it larger if the cluster network status is not good.
Finally press **Enter** at the end of cloud shell command line to start to create a new cluster.

![Set_init_timeout](../imgs/set_init_timeout.png)

## 2. Run TPC-DS with benchmark-tools

### 2.1. Update the basic configuration of Spark

#### Update the basic configuration of Spark

Run below the command to change the owner of directory`/opt/benchmark-tools`:

```
sudo chown $(whoami):$(whoami) -R /opt/benchmark-tools
```

Run the following commands to update the basic configurations for Spark:

```
git clone https://github.com/oap-project/oap-tools.git
cd oap-tools/integrations/oap/benchmark-tool/
sudo cp /lib/spark/conf/spark-defaults.conf repo/confs/spark-oap-dataproc/spark/spark-defaults.conf
```

### 2.2. Create the testing repo && config for Gazelle Plugin

#### Create the testing repo
```
mkdir ./repo/confs/gazelle_plugin_performance
```
#### Update the content of `.base` to inherit the configuration of `./repo/confs/spark-oap-dataproc`
```
echo "../spark-oap-dataproc" > ./repo/confs/gazelle_plugin_performance/.base
```
#### Update the content of `./repo/confs/gazelle_plugin_performance/env.conf`

```
NATIVE_SQL_ENGINE=TRUE
STORAGE=hdfs
```
#### Update the content of `./repo/confs/gazelle_plugin_performance/spark/spark-defaults.conf`

```
mkdir ./repo/confs/gazelle_plugin_performance/spark
```
make sure to add below configuration to `./repo/confs/gazelle_plugin_performance/spark/spark-defaults.conf`.

```
spark.driver.extraLibraryPath                /opt/benchmark-tools/oap/lib
spark.executorEnv.LD_LIBRARY_PATH            /opt/benchmark-tools/oap/lib
spark.executor.extraLibraryPath              /opt/benchmark-tools/oap/lib
spark.executorEnv.LIBARROW_DIR               /opt/benchmark-tools/oap
spark.executorEnv.CC                         /opt/benchmark-tools/oap/bin/gcc
```
Then make sure use below command to add some environment variables before start Gazelle, you can also add them to `~/.bashrc`.
```
export CC=/opt/benchmark-tools/oap/bin/gcc
export LIBARROW_DIR=/opt/benchmark-tools/oap
export LD_LIBRARY_PATH=/opt/benchmark-tools/oap/lib/:$LD_LIBRARY_PATH
```
then run
```
source ~/.bashrc
```
Here is an example of `spark-defaults.conf` on a `1 master + 2 workers` Dataproc cluster, 
you can add these items to your `./repo/confs/gazelle_plugin_performance/spark/spark-defaults.conf` and modify config according to your cluster.

```
###Enabling Gazelle Plugin###

spark.driver.extraLibraryPath                /opt/benchmark-tools/oap/lib
spark.executorEnv.LD_LIBRARY_PATH            /opt/benchmark-tools/oap/lib
spark.executor.extraLibraryPath              /opt/benchmark-tools/oap/lib
spark.executorEnv.LIBARROW_DIR               /opt/benchmark-tools/oap
spark.executorEnv.CC                         /opt/benchmark-tools/oap/bin/gcc

spark.sql.extensions  com.intel.oap.ColumnarPlugin
spark.files   /opt/benchmark-tools/oap/oap_jars/spark-columnar-core-1.2.0-snapshot-jar-with-dependencies.jar,/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-1.2.0-snapshot-jar-with-dependencies.jar
spark.driver.extraClassPath  /opt/benchmark-tools/oap/oap_jars/spark-columnar-core-1.2.0-snapshot-jar-with-dependencies.jar:/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-1.2.0-snapshot-jar-with-dependencies.jar
spark.executor.extraClassPath  /opt/benchmark-tools/oap/oap_jars/spark-columnar-core-1.2.0-snapshot-jar-with-dependencies.jar:/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-1.2.0-snapshot-jar-with-dependencies.jar

spark.master yarn
spark.deploy-mode client
spark.executor.instances 4
spark.executor.cores 2
spark.executor.memory 4g
spark.executor.memoryOverhead 2989
spark.memory.offHeap.enabled false
spark.memory.offHeap.size 3g
spark.driver.memory 2g
spark.driver.maxResultSize  3g

spark.shuffle.manager     org.apache.spark.shuffle.sort.ColumnarShuffleManager
spark.oap.sql.columnar.sortmergejoin  true
spark.oap.sql.columnar.preferColumnar true
spark.oap.sql.columnar.joinOptimizationLevel 12

spark.sql.autoBroadcastJoinThreshold 31457280
spark.sql.adaptive.enabled true
spark.sql.inMemoryColumnarStorage.batchSize 20480
spark.sql.sources.useV1SourceList avro
spark.sql.extensions com.intel.oap.ColumnarPlugin
spark.sql.columnar.window  true
spark.sql.columnar.sort  true
spark.sql.execution.arrow.maxRecordsPerBatch 20480
spark.sql.shuffle.partitions  72
spark.sql.parquet.columnarReaderBatchSize 20480
spark.sql.columnar.codegen.hashAggregate false
spark.sql.join.preferSortMergeJoin  false
spark.sql.broadcastTimeout 3600

spark.authenticate false
spark.history.ui.port 18080
spark.history.fs.cleaner.enabled true
spark.eventLog.enabled true
spark.network.timeout 3600s
spark.serializer org.apache.spark.serializer.KryoSerializer
spark.kryoserializer.buffer           64m
spark.kryoserializer.buffer.max       256m
spark.dynamicAllocation.executorIdleTimeout 3600s

spark.sql.warehouse.dir hdfs:///datagen


```

#### Define the configurations of TPC-DS

```
mkdir ./repo/confs/gazelle_plugin_performance/TPC-DS
vim ./repo/confs/gazelle_plugin_performance/TPC-DS/config
```
Add the below content to `./repo/confs/gazelle_plugin_performance/TPC-DS/config`, which will generate 1GB Parquet.
```
scale 1                    
format parquet             
partitionTables true       
queries all                
```

#### Define the configurations of TPC-H

```
mkdir ./repo/confs/gazelle_plugin_performance/TPC-H
vim ./repo/confs/gazelle_plugin_performance/TPC-H/config
```

Add the content to `./repo/confs/gazelle_plugin_performance/TPC-H/config` like below
```
scale 1                     
format parquet              
partitionTables true        
queries all               
```

### 2.3. Run TPC-DS

We provide scripts to help easily run TPC-DS and TPC-H.

```
###Update: 
bash bin/tpc_ds.sh update ./repo/confs/gazelle_plugin_performance   

###Generate data: 
bash bin/tpc_ds.sh gen_data ./repo/confs/gazelle_plugin_performance

### run power test for 1 round.

bash bin/tpc_ds.sh run ./repo/confs/gazelle_plugin_performance 1
```

### 2.4. Run TPC-H:  

```
Update: bash bin/tpc_h.sh update ./repo/confs/gazelle_plugin_performance   

bash bin/tpc_h.sh gen_data ./repo/confs/gazelle_plugin_performance

### run power test for 1 round.
bash bin/tpc_h.sh run ./repo/confs/gazelle_plugin_performance 1
```
