# Gazelle on GCP Dataproc 2.0

## 1. Creating a cluster on Dataproc 2.0

### 1.1 Uploading initialization actions

Upload the initialization actions scripts to Cloud Storage bucket.
**[bootstrap_oap.sh](../bootstrap_oap.sh)** is to help conda install OAP packages and
**[bootstrap_benchmark.sh](./bootstrap_benchmark.sh)** is to help install necessary tools for TPC-DS and HiBench on Dataproc clusters.

1). Download **[bootstrap_oap.sh](https://raw.githubusercontent.com/oap-project/oap-tools/master/integrations/oap/dataproc/bootstrap_oap.sh)** and **[bootstrap_benchmark.sh](https://raw.githubusercontent.com/oap-project/oap-tools/master/integrations/oap/dataproc/benchmark/bootstrap_benchmark.sh)** to a local folder.

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
sudo cp /etc/spark/conf/spark-defaults.conf repo/confs/spark-oap-dataproc/spark/spark-defaults.conf
```

### 2.2. Create the testing repo && config for Gazelle Plugin

#### Create the testing repo

Run the following command:

```
mkdir ./repo/confs/gazelle_plugin_performance
```
#### Update the content of `.base` to inherit the configuration of `./repo/confs/spark-oap-dataproc`

Run the following command:
```
echo "../spark-oap-dataproc" > ./repo/confs/gazelle_plugin_performance/.base
```
#### Update the content of `./repo/confs/gazelle_plugin_performance/env.conf`

Edit the `./repo/confs/gazelle_plugin_performance/env.conf` to add items below, Gazelle doesn't support GCS as storage, so choose HDFS here.

```
NATIVE_SQL_ENGINE=TRUE
STORAGE=hdfs
```
#### Update the content of `./repo/confs/gazelle_plugin_performance/spark/spark-defaults.conf`

Run the following command:

```
mkdir ./repo/confs/gazelle_plugin_performance/spark
```
make sure to add below configuration to `./repo/confs/gazelle_plugin_performance/spark/spark-defaults.conf`.

```
spark.driver.extraLibraryPath                /opt/benchmark-tools/oap/lib
spark.executorEnv.LD_LIBRARY_PATH            /opt/benchmark-tools/oap/lib
spark.executor.extraLibraryPath              /opt/benchmark-tools/oap/lib
spark.executorEnv.CC                         /opt/benchmark-tools/oap/bin/gcc
```

Here is an example of `spark-defaults.conf` on a `1 master + 2 workers` on `n2-highmem-32` Dataproc cluster, with 1TB
data scale. Each worker node has 4 local SSDs attached.
you can add these items to your `./repo/confs/gazelle_plugin_performance/spark/spark-defaults.conf` and modify config according to your cluster.

```
###Enabling Gazelle Plugin###
spark.driver.extraLibraryPath                    /opt/benchmark-tools/oap/lib
spark.executorEnv.LD_LIBRARY_PATH    /opt/benchmark-tools/oap/lib
spark.executor.extraLibraryPath              /opt/benchmark-tools/oap/lib
spark.executorEnv.CC                                /opt/benchmark-tools/oap/bin/gcc                             
spark.executorEnv.LD_PRELOAD             /usr/lib64/libjemalloc.so

spark.files   /opt/benchmark-tools/oap/oap_jars/spark-columnar-core-1.3.1-jar-with-dependencies.jar,/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-1.3.1-jar-with-dependencies.jar
spark.driver.extraClassPath  /opt/benchmark-tools/oap/oap_jars/spark-columnar-core-1.3.1-jar-with-dependencies.jar:/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-1.3.1-jar-with-dependencies.jar
spark.executor.extraClassPath /opt/benchmark-tools/oap/oap_jars/spark-columnar-core-1.3.1-jar-with-dependencies.jar:/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-1.3.1-jar-with-dependencies.jar
spark.executor.instances                         8
spark.executor.cores                             8       
spark.executor.memory                            8g
spark.memory.offHeap.enabled                     true
spark.memory.offHeap.size                        40g
spark.executor.memoryOverhead                    384
spark.sql.shuffle.partitions                     64
spark.sql.files.maxPartitionBytes                1073741824
spark.plugins                                    com.intel.oap.GazellePlugin
spark.shuffle.manager     org.apache.spark.shuffle.sort.ColumnarShuffleManager
spark.oap.sql.columnar.preferColumnar false
spark.sql.join.preferSortMergeJoin  false
spark.sql.execution.sort.spillThreshold          2147483648
spark.oap.sql.columnar.joinOptimizationLevel     18
spark.oap.sql.columnar.sortmergejoin.lazyread  true
spark.executor.extraJavaOptions   -XX:+UseParallelOldGC -XX:ParallelGCThreads=5 -XX:NewRatio=1 -XX:SurvivorRatio=1 -XX:+UseCompressedOops -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps
spark.executorEnv.ARROW_ENABLE_NULL_CHECK_FOR_GET    false
spark.sql.autoBroadcastJoinThreshold             10m
spark.kryoserializer.buffer.max                  128m
spark.oap.sql.columnar.sortmergejoin  true
spark.oap.sql.columnar.shuffle.customizedCompression.codec  lz4
spark.sql.inMemoryColumnarStorage.batchSize      20480
spark.sql.sources.useV1SourceList avro
spark.sql.columnar.window  true
spark.sql.columnar.sort  true
spark.sql.execution.arrow.maxRecordsPerBatch     20480
spark.kryoserializer.buffer                      32m
spark.sql.parquet.columnarReaderBatchSize        20480
spark.executorEnv.MALLOC_ARENA_MAX   2
spark.executorEnv.ARROW_ENABLE_UNSAFE_MEMORY_ACCESS  true
spark.oap.sql.columnar.wholestagecodegen         true
spark.serializer org.apache.spark.serializer.KryoSerializer
spark.authenticate false
spark.executorEnv.MALLOC_CONF                    background_thread:true,dirty_decay_ms:0,muzzy_decay_ms:0,narenas:2
spark.sql.columnar.codegen.hashAggregate false
spark.yarn.appMasterEnv.LD_PRELOAD           /usr/lib64/libjemalloc.so
spark.network.timeout 3600s
spark.sql.warehouse.dir hdfs:///datagen
spark.dynamicAllocation.enabled false

```
#### Define the configurations of TPC-DS

```
mkdir ./repo/confs/gazelle_plugin_performance/TPC-DS
vim ./repo/confs/gazelle_plugin_performance/TPC-DS/config
```
Add the below content to `./repo/confs/gazelle_plugin_performance/TPC-DS/config`, which will generate 1TB Parquet,

```
scale 1000
format parquet
partition 128
generate yes
partitionTables true
useDoubleForDecimal false
queries all
              
```

### 2.3. Run TPC-DS

To make the configuration above to be valid, run the following command (Note: every time you change Spark and TPC-DS configuration above, make sure to re-run this command.)
```
bash bin/tpc_ds.sh update ./repo/confs/gazelle_plugin_performance   
```

Generate data:
```
bash bin/tpc_ds.sh gen_data ./repo/confs/gazelle_plugin_performance
```

Run power test for 1 round.
```
bash bin/tpc_ds.sh run ./repo/confs/gazelle_plugin_performance 1
```
