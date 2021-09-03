# SQL DS Cache on GCP Dataproc 2.0

## 1. Creating a cluster on Dataproc

### 1.1 Uploading initialization actions

Upload the initialization actions scripts to Cloud Storage bucket. 
**[bootstrap_oap.sh](../bootstrap_oap.sh)** is to help conda install OAP packages and
**[bootstrap_benchmark.sh](./bootstrap_benchmark.sh)** is to help install necessary tools for TPC-DS and HiBench on Dataproc clusters.
    
1). Download **[bootstrap_oap.sh](https://raw.githubusercontent.com/oap-project/oap-tools/master/integrations/oap/dataproc/bootstrap_oap.sh)** and **[bootstrap_benchmark.sh](https://github.com/oap-project/oap-tools/blob/master/integrations/oap/dataproc/benchmark/bootstrap_benchmark.sh)** to a local folder.

2). Upload these scripts to bucket.

![upload_init_script and bootstrap_benchmark.sh](../imgs/upload_scripts_to_bucket.png)


### 1.2 Create a new cluster with initialization actions

To create a new cluster with initialization actions, follow the steps below:

1). Click the  **CREATE CLUSTER** to create and custom your cluster.

2). **Set up cluster:** choose cluster type and Dataproc image version `2.0-centos8`, enable component gateway, and add Jupyter Notebook, ZooKeeper.
![Enable_component_gateway](../imgs/component_gateway.png)

3). **Configure nodes:** choose the instance type and other configurations of nodes.

4). **Customize cluster:** add initialization actions as below;

5). **Manage security:** define the permissions and other security configurations;

6). Click **EQUIVALENT COMMAND LINE**, then click **RUN IN CLOUD SHELL** to add argument ` --initialization-action-timeout 60m ` to your command,
which sets timeout period for the initialization action to 60 minutes and the default timeout value is 10 minutes. You can also set it larger if the cluster network status is not good.
Finally press **Enter** at the end of cloud shell command line to start to create a new cluster.

![Set_init_timeout](../imgs/set_init_timeout.png) 

## 2. Configuration for enabling YARN services Rest API on ResourceManager

***Modify `/etc/hadoop/conf/yarn-site.xml` on master***

```
sudo vim /etc/hadoop/conf/yarn-site.xml
```

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
Then **restart** ResourceManager with below command:

```
###change to root user
sudo -i
systemctl restart hadoop-yarn-resourcemanager
```
Then change back to your account with below command:
```
exit
```

## 3. Run TPC-DS with benchmark-tools

### 3.1. Update the basic configuration of spark

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

### 3.2. Create the testing repo && Config SQL DS Cache

#### Create the testing repo
```
mkdir ./repo/confs/sql-ds-cache-performance
```
#### Update the content of `.base` to inherit the configuration of `./repo/confs/spark-oap-dataproc`

Run the following command:
```
echo "../spark-oap-dataproc" > ./repo/confs/sql-ds-cache-performance/.base
```

#### Update the content of `./repo/confs/sql-ds-cache-performance/env.conf`

If you use HDFS as storage, add items below:
```
OAP_with_external=TRUE
STORAGE=hdfs
```
If you use Google Cloud Storage as storage, add items below:
```
OAP_with_external=TRUE
STORAGE=gs
BUCKET={your_bucket}
```

#### Modify `spark-defaults.conf` to enable SQL DS Cache

```
mkdir ./repo/confs/sql-ds-cache-performance/spark
vim ./repo/confs/sql-ds-cache-performance/spark/spark-defaults.conf
```

If choosing HDFS, add below item to `./repo/confs/sql-ds-cache-performance/spark/spark-defaults.conf`
```
spark.sql.warehouse.dir hdfs:///datagen 
```

If choosing GCS, add below item to `./repo/confs/sql-ds-cache-performance/spark/spark-defaults.conf`
```
spark.sql.warehouse.dir  gs://<your_bucket>/
```
Here is an example of `spark-defaults.conf` on a `1 master + 2 workers` Dataproc cluster, 
you can add these items to your `./repo/confs/sql-ds-cache-performance/spark/spark-defaults.conf` and modify config according to your cluster.

```
### OAP

spark.files   /opt/benchmark-tools/oap/oap_jars/plasma-sql-ds-cache-1.2.0-with-spark-3.1.1.jar,/opt/benchmark-tools/oap/oap_jars/pmem-common-1.2.0-with-spark-3.1.1.jar,/opt/benchmark-tools/oap/oap_jars/arrow-plasma-4.0.0.jar
spark.driver.extraClassPath  /opt/benchmark-tools/oap/oap_jars/plasma-sql-ds-cache-1.2.0-with-spark-3.1.1.jar:/opt/benchmark-tools/oap/oap_jars/pmem-common-1.2.0-with-spark-3.1.1.jar:/opt/benchmark-tools/oap/oap_jars/arrow-plasma-4.0.0.jar
spark.executor.extraClassPath  ./plasma-sql-ds-cache-1.2.0-with-spark-3.1.1.jar:./pmem-common-1.2.0-with-spark-3.1.1.jar:./arrow-plasma-4.0.0.jar


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
# cache size 
spark.executor.sql.oap.cache.persistent.memory.initial.size  50g

spark.executorEnv.LD_LIBRARY_PATH   /opt/benchmark-tools/oap/lib
spark.driver.extraLibraryPath       /opt/benchmark-tools/oap/lib
```

#### Modify `<replace-with-cache-storage-path>`  in  `tools/plasma/plasmaLaunch.json`

```
 "launch_command": "{%oap.home%}/bin/plasma-store-server -m {%plasma.cache.size%} -s /tmp/plasmaStore -d <replace-with-cache-storage-path>",
```
Replace the <replace-with-cache-storage-path> to PMem or disk path on workers which is set 777 permission.

For example, the first SSD will be mounted on `/mnt/1`, and you choose the first SSD as caching path, then you can use `/mnt/1/hadoop/spark` path which is set 777 permission on workers by default. 

#### Define the configurations of TPC-DS

```
mkdir  ./repo/confs/sql-ds-cache-performance/TPC-DS
vim ./repo/confs/sql-ds-cache-performance/TPC-DS/config
```

Add the below content to `./repo/confs/sql-ds-cache-performance/TPC-DS/config`, which will generate 1GB Parquet.

```
scale 1                  
format parquet           
partitionTables true     
queries all             
```


### 3.3. Run TPC-DS

We provide scripts to help easily run TPC-DS.

To make the configuration above to be valid, run the following command (Note: every time you change Spark and TPC-DS configuration above, make sure to re-run this command.)

```
bash bin/tpc_ds.sh update ./repo/confs/sql-ds-cache-performance
```

Generate data:
``` 
bash bin/tpc_ds.sh gen_data ./repo/confs/sql-ds-cache-performance
```

Run power test for 1 round.
```
bash bin/tpc_ds.sh run ./repo/confs/sql-ds-cache-performance 1
```
