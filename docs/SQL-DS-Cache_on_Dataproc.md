# SQL DS Cache on GCP Dataproc 2.0

## 1. Creating a cluster on Dataproc

### 1.1 Uploading initialization actions

Upload the initialization actions scripts to Cloud Storage bucket. 
**[bootstrap_oap.sh](../integrations/oap/dataproc/bootstrap_oap.sh)** is to help conda install OAP packages and
**[bootstrap_benchmark.sh](../integrations/oap/dataproc/benchmark/bootstrap_benchmark.sh)** is to help install necessary tools for TPC-DS, TPC-H and HIBench on Dataproc clusters.
    
1). Download **[bootstrap_oap.sh](../integrations/oap/dataproc/bootstrap_oap.sh)** and **[bootstrap_benchmark.sh](../integrations/oap/dataproc/benchmark/bootstrap_benchmark.sh)** to a local folder.

2). Upload these scripts to bucket.

![upload_init_script and bootstrap_benchmark.sh](../integrations/oap/dataproc/imgs/upload_scripts_to_bucket.png)


### 1.2 Create a new cluster with initialization actions

To create a new cluster with initialization actions, follow the steps below:

1). Click the  **CREATE CLUSTER** to create and custom your cluster.

2). **Set up cluster:** choose cluster type and Dataproc image version `2.0-centos8`, enable component gateway, and add Jupyter Notebook.
![Enable_component_gateway](../integrations/oap/dataproc/imgs/component_gateway.png)

3). **Configure nodes:** choose the instance type and other configurations of nodes.

4). **Customize cluster:** add initialization actions as below;
![Add bootstrap action](../integrations/oap/dataproc/imgs/add_scripts.png)

5). **Manage security:** define the permissions and other security configurations;

6). Click **Create**. 

## 2. Configurations for enabling SQL-DS-Cache

### 2.1. Modifications on master

#### HDFS 

Create a directory on HDFS 
```
$ hadoop fs -mkdir /spark-warehouse
```

#### Hive 

Modify `hive-site.xml` on master, change the default `hive.execution.engine` from `tez` to `spark`

```
 <property>
    <name>hive.execution.engine</name>
    <value>spark</value>
 </property>
```

Then stop HiveServer2 with the following command  

```
sudo netstat -antlp | grep 10000|awk -F/ '{print $1}'|awk '{print $7}'|sudo xargs kill -9
```

### 2.2. Config to enable SQL-DS-Cache

***Modify `$SPARK_HOME/conf/spark-defaults.conf`.***

**[bootstrap_oap.sh](../integrations/oap/dataproc/bootstrap_oap.sh)** will help install all OAP packages under dir `/opt/benchmark-tools/oap`,
make sure to add below configuration to `spark-defaults.conf`.

```
spark.executorEnv.LD_LIBRARY_PATH   /opt/benchmark-tools/oap/lib
spark.driver.extraLibraryPath       /opt/benchmark-tools/oap/lib
```

Here is an example of `spark-defaults.conf` on a `1 master + 2 workers` Dataproc cluster.

```
### OAP
spark.sql.warehouse.dir hdfs://cluster-dev-m/spark-warehouse

spark.files   /opt/benchmark-tools/oap/oap_jars/plasma-sql-ds-cache-1.2.0-snapshot-with-spark-3.1.1.jar,/opt/benchmark-tools/oap/oap_jars/pmem-common-1.2.0-snapshot-with-spark-3.1.1.jar,/opt/benchmark-tools/oap/oap_jars/arrow-plasma-4.0.0.jar
spark.driver.extraClassPath  /opt/benchmark-tools/oap/oap_jars/plasma-sql-ds-cache-1.2.0-snapshot-with-spark-3.1.1.jar:/opt/benchmark-tools/oap/oap_jars/pmem-common-1.2.0-snapshot-with-spark-3.1.1.jar:/opt/benchmark-tools/oap/oap_jars/arrow-plasma-4.0.0.jar
spark.executor.extraClassPath  ./plasma-sql-ds-cache-1.2.0-snapshot-with-spark-3.1.1.jar:./pmem-common-1.2.0-snapshot-with-spark-3.1.1.jar:./arrow-plasma-4.0.0.jar


spark.master yarn
spark.kryoserializer.buffer.max       256m
spark.executor.memory 4g
spark.deploy-mode client
spark.executor.cores 2

spark.driver.memory 2g
spark.network.timeout 3600s
spark.memory.offHeap.enabled false
spark.eventLog.enabled true
spark.executor.instances 4
spark.driver.maxResultSize  3g
spark.history.fs.cleaner.enabled true
spark.history.ui.port 18080
spark.serializer org.apache.spark.serializer.KryoSerializer
spark.authenticate false


spark.sql.extensions              org.apache.spark.sql.OapExtensions
# for parquet file format, enable binary cache
spark.sql.oap.parquet.binary.cache.enabled                   true
spark.oap.cache.strategy                                     external
spark.sql.oap.dcpmm.free.wait.threshold                      50000000000
spark.executor.sql.oap.cache.external.client.pool.size       2

spark.executorEnv.LD_LIBRARY_PATH   /opt/benchmark-tools/oap/lib
spark.driver.extraLibraryPath       /opt/benchmark-tools/oap/lib
```

***Modify `/etc/hadoop/conf/yarn-site.xml`.***

Delete the property below:

```
 <property>
    <name>yarn.resourcemanager.webapp.methods-allowed</name>
    <value>GET,HEAD</value>
    <description>
      The HTTP methods allowed by the YARN Resource Manager web UI and REST API.
    </description>
 </property>
```
and add the property to enable YARN services Rest API on ResourceManager.

```
<property>
    <description>
      Enable services rest api on ResourceManager.
    </description>
    <name>yarn.webapp.api-service.enable</name>
    <value>true</value>
</property>
```

***Use Yarn to start Plasma service***

When using Yarn(Hadoop version >= 3.1) to start Plasma service, you should provide a json file `/tmp/plasmaLaunch.json` as below.

```
{
  "name": "plasma-store-services",
  "version": 1,
  "components" :
  [
   {
     "name": "plasma-store-service",
     "number_of_containers": 2,
     "launch_command": "/opt/benchmark-tools/oap/bin/plasma-store-server -m 15000000000 -s /tmp/plasmaStore -d /mnt/pmem",
     "resource": {
       "cpus": 1,
       "memory": 512
     }
   }
  ]
}

```
Run command `yarn app -launch oap-plasma-store-service /tmp/plasmaLaunch.json` to start Plasma server.
Run `yarn app -stop plasma-store-service` to stop it.
Run `yarn app -destroy plasma-store-service` to destroy it.



## 3. Run TPC-DS

We provide scripts **[run_benchmark.sh](../integrations/oap/dataproc/benchmark/run_benchmark.sh)** to help easily run TPC-DS and TPC-H.

```
Generate data: sh run_benchmark.sh -g|--gen   -w|--workload tpcds -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] -d|--doubleForDecimal -p|--partitionTables --Port [8020|customed hdfs port]   
Run benchmark: sh run_benchmark.sh -r|--rerun -w|--workload tpcds -f|--format [parquet|orc|arrow] -i|--iteration [1|custom the interation you want to run]  -s|--scaleFactor [10|custom the data scale,the unit is GB]  -p|--partitionTables --Port [8020|customed hdfs port]   
```

Only after enabling SQL-DS-Cache can you run TPC-DS or TPC-H with arrow format.

Example: generate 1GB Parquet, then run TPC-DS all queries with SQL-DS-Cache enabled.

```
# generate 1GB Parquet 
sh run_benchmark.sh -g -w tpcds -f parquet  -s 1 -d -p --Port 8020

# after start Plasma service with YARN, then run TPC-DS
sh run_benchmark.sh -r -w tpcds -f parquet  -s 1 -i 1 -p --Port  8020

```

### 4. Run TPC-H:  
```
Generate data: ./run_benchmark.sh -g|--gen   -w|--workload tpch  -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] -d|--doubleForDecimal -p|--partitionTables --Port [8020|customed hdfs port]  
Run benchmark: ./run_benchmark.sh -r|--rerun -w|--workload tpch  -f|--format [parquet|orc|arrow] -i|--iteration [1|custom the interation you want to run] -s|--scaleFactor [10|custom the data scale,the unit is GB] -p|--partitionTables --Port [8020|customed hdfs port] 
``` 
