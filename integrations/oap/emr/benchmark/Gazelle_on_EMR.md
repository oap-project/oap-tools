# Gazelle on EMR 6.3.0

## 1. Create a new cluster

To run bencbmark on EMR cluster with OAP, you need upload both **[bootstrap_benchmark.sh](https://raw.githubusercontent.com/oap-project/oap-tools/branch-1.2/integrations/oap/emr/benchmark/bootstrap_benchmark.sh)** and **[bootstrap_oap.sh](https://raw.githubusercontent.com/oap-project/oap-tools/branch-1.2/integrations/oap/emr/bootstrap_oap.sh)** to S3 and add extra bootstrap action to execute **[bootstrap_benchmark.sh](https://raw.githubusercontent.com/oap-project/oap-tools/branch-1.2/integrations/oap/emr/benchmark/bootstrap_benchmark.sh)** and **[bootstrap_oap.sh](https://raw.githubusercontent.com/oap-project/oap-tools/branch-1.2/integrations/oap/emr/bootstrap_oap.sh)** when creating a new cluster.

![upload_init_script and install_benchmark.sh](../imgs/upload_all_scripts_to_S3.PNG)

![Add bootstrap action](../imgs/add-bootstrap-benchmark.PNG) 

## 2. Using benchmark-tools to easily run TPC-DS or TPC-H with Gazelle

You can refer to [benchmark-tool Guide](../../benchmark-tool/README.md) to learn how to use this tool. We switch working directory at ```../../benchmark-tool``` and follow next steps.

### 2.1. Update the basic configuration of spark

#### Update the basic configuration of spark
```
$ sudo cp /lib/spark/conf/spark-defaults.conf ./repo/confs/spark-oap-emr/spark/spark-defaults.conf;
```

### 2.2. Create the testing repo && Config gazelle_plugin

#### Create the testing repo
```
mkdir ./repo/confs/gazelle_plugin_performance
```
#### Update the content of .base to inherit the configuration of ./repo/confs/spark-oap-emr
```
echo "../spark-oap-emr" > ./repo/confs/gazelle_plugin_performance/.base
```
#### Update the content of ./repo/confs/gazelle_plugin_performance/env.conf
```
NATIVE_SQL_ENGINE=TRUE
STORAGE=s3
BUCKET={bucket_name}
```
Note: If you want to use s3 for storage, you must define BUCKET; if you use hdfs for storage, you should set STORAGE like ```STORAGE=hdfs```

#### Update the configurations of spark
**[bootstrap_oap.sh](https://raw.githubusercontent.com/oap-project/oap-tools/branch-1.2/integrations/oap/emr/bootstrap_oap.sh)** will help install all OAP packages under dir `/opt/benchmark-tools/oap`,
make sure to add below configuration to `./repo/confs/gazelle_plugin_performance/spark/spark-defaults.conf`.

```
++spark.driver.extraLibraryPath   :/opt/benchmark-tools/oap/lib
++spark.driver.extraClassPath     :/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-<oap.version>-jar-with-dependencies.jar:/opt/benchmark-tools/oap/oap_jars/spark-columnar-core-<oap.version>-jar-with-dependencies.jar

++spark.executor.extraLibraryPath :/opt/benchmark-tools/oap/lib
++spark.executor.extraClassPath   :/opt/benchmark-tools/oap/oap_jars/spark-arrow-datasource-standard-<oap.version>-jar-with-dependencies.jar:/opt/benchmark-tools/oap/oap_jars/spark-columnar-core-<oap.version>-jar-with-dependencies.jar

spark.executor.defaultJavaOptions -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:OnOutOfMemoryError='kill -9 %p' -XX:MaxDirectMemorySize=40G
spark.executorEnv.CC                            /opt/benchmark-tools/oap/bin/gcc
spark.executorEnv.CXX                           /opt/benchmark-tools/oap/bin/g++
spark.executorEnv.CPLUS_INCLUDE_PATH            /opt/benchmark-tools/oap/include
spark.executorEnv.LD_LIBRARY_PATH               /opt/benchmark-tools/oap/lib
spark.sql.extensions                            com.intel.oap.ColumnarPlugin
spark.shuffle.manager                           org.apache.spark.shuffle.sort.ColumnarShuffleManager
spark.sql.join.preferSortMergeJoin              false
spark.sql.inMemoryColumnarStorage.batchSize     20480
spark.sql.parquet.columnarReaderBatchSize       20480
spark.sql.execution.arrow.maxRecordsPerBatch    20480
spark.executor.memoryOverhead                   512m
spark.sql.autoBroadcastJoinThreshold            10485760
spark.driver.maxResultSize                      1g
spark.sql.shuffle.partitions                    200
spark.memory.offHeap.enabled                    false
spark.memory.offHeap.size                       10g
spark.sql.adaptive.enabled                      false
spark.sql.sources.useV1SourceList               avro
spark.driver.userClassPathFirst                 true
spark.executor.userClassPathFirst               true
```
Note: "++" means to append the value of spark to the end of original value.


#### Define the configurations of TPC-DS

Edit the content of `./repo/confs/gazelle_plugin_performance/TPC-DS/config`
```
scale 1                    // data scale/GB
format parquet             // support parquet or orc
partitionTables true       // creating partitioned tables
queries all                // 'all' means running 99 queries, '1,2,4,6' means running q1.sql, q2.sql, q4.sql, q6.sql
```

#### Define the configurations of TPC-H

Edit the content of `./repo/confs/gazelle_plugin_performance/TPC-H/config`
```
scale 1                    // data scale 1 GB
format parquet             // support parquet or orc
partitionTables true       // creating partitioned tables
queries all                // 'all' means running 22 queries, '1,2,4,6' means running 1.sql, 2.sql, 4.sql, 6.sql
```


### 2.3. Run TPC-DS

We provide scripts to help easily run TPC-DS and TPC-H.

```
Update: bash bin/tpc_ds.sh update ./repo/confs/gazelle_plugin_performance   

Generate data: bash bin/tpc_ds.sh gen_data ./repo/confs/gazelle_plugin_performance

### run power test for 1 round.
Run benchmark: bash bin/tpc_ds.sh run ./repo/confs/gazelle_plugin_performance 1
```

### 2.4. Run TPC-H:  

```
Update: bash bin/tpc_h.sh update ./repo/confs/gazelle_plugin_performance   

Generate data: bash bin/tpc_h.sh gen_data ./repo/confs/gazelle_plugin_performance

### run power test for 1 round.
Run benchmark: bash bin/tpc_h.sh run ./repo/confs/gazelle_plugin_performance 1
```
