# Running Benchmark Automation on Cloud with OAP

This guide helps run different workloads easily on Cloud Platforms. It also provides the function to run workflow.

## 1. Create a new cluster on Cloud

### 1.1 AWS EMR

If you are using AWS EMR, you can refer [OAP integrate EMR](../emr/README.md) to create a new cluster. To run benchmark on EMR cluster with OAP, you also need to upload both **[bootstrap_benchmark.sh](../emr/benchmark/bootstrap_benchmark.sh)** and **[bootstrap_oap.sh](../emr/bootstrap_oap.sh)** to S3 and add extra bootstrap action to execute **[bootstrap_benchmark.sh](../emr/benchmark/bootstrap_benchmark.sh)** and **[bootstrap_oap.sh](../emr/bootstrap_oap.sh)** when creating a new cluster.

![upload_init_script and install_benchmark.sh](../emr/imgs/upload_all_scripts_to_S3.PNG)

![Add bootstrap action](../emr/imgs/add-bootstrap-benchmark.PNG) 

### 1.2 Google Cloud Dataproc

If you are using Google Cloud Dataproc, please refer to [OAP on Dataproc](../dataproc/README.md) to create a new cluster.
To run benchmark on Dataproc cluster, you also need to upload **[bootstrap_benchmark.sh](../dataproc/benchmark/bootstrap_benchmark.sh)** to bucket 
then add initialization actions **[bootstrap_benchmark.sh](../emr/benchmark/bootstrap_benchmark.sh)** as below when creating a new cluster.

![upload_init_script and install_benchmark.sh](../dataproc/imgs/upload_scripts_to_bucket.png)

![Add bootstrap action](../dataproc/imgs/add_scripts.png) 




## 2. Update the basic configurations for spark

Git clone oap-tools repo to Cloud
 
```
git clone https://github.com/oap-project/oap-tools.git
cd oap-tools/integrations/oap/benchmark-tool/
```

### 2.1 AWS EMR

Make sure the primary node has python2 installed;
If you use AWS EMR, please execute the following commands to update the basic configurations for spark:

```sudo cp /lib/spark/conf/spark-defaults.conf repo/confs/spark-oap-emr/spark/spark-defaults.conf;```

```sudo cp /lib/spark/conf/spark-defaults.conf repo/confs/spark-oap-emr/hibench/spark.conf;```

### 2.2 Google Cloud Dataproc

Make sure the primary node has python2 installed.

If you use Dataproc, please execute the following commands to update the basic configurations for spark:

```sudo cp /lib/spark/conf/spark-defaults.conf repo/confs/spark-oap-dataproc/spark/spark-defaults.conf```

```sudo cp /lib/spark/conf/spark-defaults.conf repo/confs/spark-oap-dataproc/hibench/spark.conf```


## 3. Config Rules to Follow && Create a configuration folder ##

We organized the configurations in an inheritance hierarchy to make your own configuration as minimum as possible.

* When you run your own cluster, start from an empty conf folder. By default, your empty folder will inherit all the properties in the ```./conf``` folder. So Don't try to make changes in the ```./conf``` unless we want to make the change apply to all.

* When you have an empty folder, only add new changes for config files to the folder. Don’t copy the whole config file from ```./conf```. Instead, create an empty file and add only the values that you need change. The unchanged values will inherit from ```./conf``` folder.

* There are other conf folders in the repo which also inherit from ```./conf``` folder. 
You can inherit from the conf in repo by creating a ```.base``` file in your conf folder and put the relative path to the conf you want to inherit in the first line. 

* For example, we've created the repo ```repo/confs/spark-oap-emr```for the users who want to run tests on EMR cluster. 
Please follow prerequisites to update default configurations of spark. 
If you want to inherit all configurations of ```repo/confs/spark-oap-emr```, please create a new directory in ```./repo/confs```with a meaningful name which will act as your configuration root for your workload and update the content of ```.base```.

```
mkdir ./repo/confs/testconf

#####EMR
echo "../spark-oap-emr" > ./repo/confs/testconf/.base

#####Dataproc
echo "../spark-oap-dataproc" > ./repo/confs/testconf/.base
```
* When you want to use HDFS or S3 for storage, you need to edit `./repo/confs/testconf/env.conf` and add content like:
```
STORAGE=s3
S3_BUCKET={bucket_name}
```
Note: If you want to use s3 for storage, you must define S3_BUCKET; if you use hdfs for storage, you should only set STORAGE like: 
```
STORAGE=hdfs
```

## 4. Run TPC-DS #

### 4.1 Update ###

If you have made some changes in the parameter and need to reapply the parameters to the cluster configuration, such as some changes for spark, you need to edit ./repo/confs/testconf/spark/spark-defaults.conf like:
```
spark.sql.autoBroadcastJoinThreshold 31457280
spark.sql.broadcastTimeout 3600
spark.dynamicAllocation.executorIdleTimeout 7200000s
```
Then you can execute update action:

```
bash bin/tpc_ds.sh update ./repo/confs/testconf
```
Note: Updating step is neccessary to be executed even if you don't have any changes.
### 4.2 Generate data ###

The first step to run TPC-DS is to generate data. To specify the data scale, data format you want, in the TPC-DS folder in your conf folder, create a file named ```config``` :
```
vim repo/confs/testconf/config
```
and add the scale and format value, such as below:

```
scale 1
format parquet
partitionTables true
useDoubleForDecimal false
queries all
```

config to generate 1GB scale, parquet format and partitioned table. Refer to ```./conf/TPC-DS/config``` if you want to change other aspects. And then execute the below command to gen data.

```
bash bin/tpc_ds.sh gen_data ./repo/confs/testconf
```

### 4.3 Run ###

Once the data is generated, you can execute the following command to run TPCDS queries:

```
bash bin/tpc_ds.sh run ./repo/confs/testconf 1
```

The third parameter above is the iteration to run.


## 5. Run TPC-H ##

### 5.1 Update ###

The step of updating for TPC-H is similar to TPC-DS.

```
bash bin/tpc_h.sh update ./repo/confs/testconf
```
Note: Updating step is neccessary to be executed even if you don't have any changes.
### 5.2 Generate data ###

To specify the data scale, data format you want, in the TPC-H folder in your conf folder, create a file named ```config``` and add the scale and format value, for example:

```
scale 1
format parquet
partition 1
queries all
partitionTables true
useDoubleForDecimal false
```

Refer to ```./conf/TPC-H/config``` if you want to change other aspects. And then execute the below command to gen data.

```
bash bin/tpc_h.sh update ./repo/confs/testconf
bash bin/tpc_h.sh gen_data ./repo/confs/testconf
```

### 5.3 Run ###

After the data is generated, you can execute the following command to run TPCH queries:

```
bash bin/tpc_h.sh run ./repo/confs/testconf 1
```

## 6. Run HiBench ##

You need to refer to the [Hibench Guide](https://github.com/Intel-bigdata/HiBench) to learn more about HiBench.

### 6.1 Update ###

If you have some changes for spark, you need to create the file ./repo/confs/hibench/spark.conf and add the parameters you want to change such as:
```
hibench.yarn.executor.num     2
hibench.yarn.executor.cores   4
```
Note: If you use HiBench scripts to submit spark job, you must define the parameter ```hibench.yarn.executor.num```

Then you can update the parameters for the cluster:

```
bash bin/hibench.sh update ./repo/confs/testconf
```
Note: Updating step is neccessary to be executed even if you don't have any changes.

### 6.2 Generate data ###

HiBench supports various workloads such as K-means, terasort, ALS, PCA etc. And it also provide ```hibench.scale.profile``` to define the data scale for different benchmark. To specify the data scale, you need to create the file ./repo/confs/testconf/hibench/hibench.conf and edit it like:

```
hibench.scale.profile                small
```

Refer to ```./conf/hibench/hibench.conf``` if you want to change other aspects. And then execute the below command to gen data.

```
bash bin/hibench.sh update ./repo/confs/testconf
bash bin/hibench.sh gen_data ./repo/confs/testconf ml/kmeans
```
Note: ```hibench.scale.profile``` support tiny, small, large, huge, gigantic, bigdata. We also need to  input which workload we want to generate data for such as ml/kmeans, micro/terasort, ml/pca etc.

### 6.3 Run ###

After the data is generated, you can execute the following command to run HiBench workload:

```
bash bin/hibench.sh run ./repo/confs/testconf ml/kmeans
```

## 7. Run HiBench, TPC-DS, TPC-H with OAP

Please follow [Gazelle_on_EMR.md](../emr/benchmark/Gazelle_on_EMR.md) or [Gazelle_on_Dataproc.md](../dataproc/benchmark/Gazelle_on_Dataproc.md) to run TPC-DS or TPC-H with Gazelle_plugin.

Please follow [SQL_DS_Cache_on_Dataproc.md](../dataproc/benchmark/SQL_DS_Cache_on_Dataproc.md) to run TPC-DS with SQL DS Cache.

Please follow [Intel_MLlib_on_EMR.md](../emr/benchmark/Intel_MLlib_on_EMR.md) or [OAP_MLlib_on_EMR.md](../dataproc/benchmark/OAP_MLlib_on_Dataproc.md)to run K-means, PAC, ALS with Intel-MLlib.


## 8. Run workflow ##


### 8.1 Prepare workflow  ###

There are one repo in ```./repo/workflows/``` named ```oap_release_performance_test_on_EMR``` which provide default configuration for different cases. Please create a repo  with the same structure and update the values you need.

For example: we create the workflow directory as ```OAP_1.2_function_test``` in the directory ```./repo/workflows/```  and update ```./repo/OAP_1.2_function_test/.base``` to inherit ```./repo/workflows/oap_release_performance_test_on_EMR```
```
# In file .base
../oap_release_performance_test_on_EMR
```

### 8.2 Trick release test ###

Exec:

```
python ./bin/run_workflows.py --workflows ./repo/workflows/OAP_1.2_function_test
```
