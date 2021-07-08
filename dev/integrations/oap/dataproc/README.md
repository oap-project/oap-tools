# Use OAP on Google Cloud Dataproc

## 1. Initialization actions

Upload the initialization actions script **[bootstrap_oap.sh](./bootstrap_oap.sh)** to Cloud Storage staging bucket:
    
1. Download **[bootstrap_oap.sh](./bootstrap_oap.sh)** to a local folder.
2. Upload **[bootstrap_oap.sh](./bootstrap_oap.sh)** to bucket.

![upload_init_script and install_benchmark.sh](./imgs/upload_scripts_to_bucket.png)


## 2. Create a new cluster using bootstrap script
To create a new cluster with initialization actions, follow the steps below:

1). Click the  **CREATE CLUSTER** to create and custom your cluster.

2). **Set up cluster:** choose cluster type and Dataproc image version, enable component gateway.
![Enable_component_gateway](./imgs/component_gateway.png)

3). **Configure nodes:** choose the instance type and other configurations of nodes.

4). **Customize cluster:** add initialization actions as below;
![Add bootstrap action](./imgs/add_scripts.png)

5). **Manage security:** define the permissions and other security configurations;

6). Click **Create**. 

## 3. Run benchmark easily by using **[run_benchmark.sh](./benchmark/run_benchmark.sh)**

The script supports to run TPC-DS, TPC-H and HiBench easily. Before you use **[run_benchmark.sh](./benchmark/run_benchmark.sh)**, you should add **[install_benchmark.sh](./benchmark/install_benchmark.sh)** script for bootstrap action when creating a cluster.(Note: you can refer to the step to add **[bootstrap_oap.sh](./bootstrap_oap.sh)**.)  
![Add bootstrap action](./imgs/add_scripts.png)

If you want to run benchmark by using [OAP](https://github.com/oap-project/sql-ds-cache.git), you should follow the [OAP user guild](https://github.com/oap-project/oap-tools/blob/v1.1.1-spark-3.1.1/docs/OAP-Installation-Guide.md) to configure `/usr/lib/spark/conf/spark-defaults.conf` when running TPC-DS and TPC-H or configure `/opt/benchmark-tools/HiBench/conf/spark.conf` when running HiBench.  

### 1. Run HiBench
You need to follow the [Hibench Guide](https://github.com/Intel-bigdata/HiBench) to config `/opt/benchmark-tools/HiBench/conf/spark.conf` and `/opt/benchmark-tools/HiBench/conf/hadoop.conf`. This is the example to run K-means by using OAP-MLlib:

To edit `/opt/benchmark-tools/HiBench/conf/spark.conf`:
```
hibench.spark.home                /usr/lib/spark/
hibench.spark.master              yarn
spark.files                       /opt/benchmark-tools/oap/oap_jars/oap-mllib-1.1.1.jar
spark.executor.extraClassPath     ./oap-mllib-1.1.1.jar
spark.driver.extraClassPath       /opt/benchmark-tools/oap/oap_jars/oap-mllib-1.1.1.jar
hibench.yarn.executor.num         2
hibench.yarn.executor.cores       4
spark.executor.memory             2g
spark.executor.memoryOverhead     1g
spark.driver.memory               1g
```
To edit `/opt/benchmark-tools/HiBench/conf/hadoop.conf`:
```
hibench.hadoop.home               /usr/lib/hadoop/
```
To generate data or run workload:
```  
Generate data: ./run_benchmark.sh -g|--gen   -w|--workload hibench -W|--hibenchWorkload [ml/kmeans|micro/terasort|..] -P|--hibenchProfile [tiny|small|large|huge|gigantic|bigdata] --Port [8020|customed hdfs port]  
Run benchmark: ./run_benchmark.sh -r|--rerun -w|--workload hibench -W|--hibenchWorkload [ml/kmeans|micro/terasort|..] -P|--hibenchProfile [tiny|small|large|huge|gigantic|bigdata] --Port [8020|customed hdfs port]
```

### 3. Run TPC-DS:  
```
Generate data: ./run_benchmark.sh -g|--gen   -w|--workload tpcds -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] -d|--doubleForDecimal -p|--partitionTables --Port [8020|customed hdfs port]   
Run benchmark: ./run_benchmark.sh -r|--rerun -w|--workload tpcds -f|--format [parquet|orc|arrow] -i|--iteration [1|custom the interation you want to run]  -s|--scaleFactor [10|custom the data scale,the unit is GB]  -p|--partitionTables --Port [8020|customed hdfs port]   
```
Only after enabling Gazelle Plugin can you run TPC-DS or TPC-H with arrow format.

Example: generate 1GB Parquet, then run TPC-DS all queries with Gazelle enabled.

```
# generate data
./run_benchmark.sh -g -w tpcds -f parquet  -s 1 -d -p --Port 8020

# run TPC-DS
./run_benchmark.sh -r -w tpcds -f arrow -s 1 -i 1 -p --Port  8020
```

### 4. Run TPC-H:  
```
Generate data: ./run_benchmark.sh -g|--gen   -w|--workload tpch  -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] -d|--doubleForDecimal -p|--partitionTables --Port [8020|customed hdfs port]  
Run benchmark: ./run_benchmark.sh -r|--rerun -w|--workload tpch  -f|--format [parquet|orc|arrow] -i|--iteration [1|custom the interation you want to run] -s|--scaleFactor [10|custom the data scale,the unit is GB] -p|--partitionTables --Port [8020|customed hdfs port] 
``` 

