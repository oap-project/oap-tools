# Use OAP on Amazon EMR cloud

## 1. Upload init script 

Upload the init script **[init_oap.sh](./init_oap.sh)** and **[install_benchmark.sh](./benchmark/install_benchmark.sh)** and to S3:
    
1. Download **[init_oap.sh](./init_oap.sh)** and **[install_benchmark.sh](./benchmark/install_benchmark.sh)** to a local folder.
2. Update **[init_oap.sh](./init_oap.sh)** and **[install_benchmark.sh](./benchmark/install_benchmark.sh)** to S3.

![upload_init_script and install_benchmark.sh](./imgs/upload_scripts_to_S3.png)


## 2. Create a new cluster using init script and installing benchmark tools
To create a new cluster using the uploaded init script, follow the following steps:

1. Click the  **Go to advanced options** to custom your cluster;
2. **Software and Steps:** choose the release of emr and the software you need;
3. **Hardware:** choose the instance type and other configurations of hardware;
4. **General Cluster Settings:** add bootstrap action and add **[init_oap.sh](./init_oap.sh)** and **[install_benchmark.sh](./benchmark/install_benchmark.sh)** like following picture;
![Add bootstrap action](./imgs/add-scripts-to-bootstrap-action.png)
5. **Security:** define the permissions and other security configurations;
6. Click **Create cluster**. 

![create_cluster](./imgs/create-oap-cluster.png)

## 3. Run benchmark easily by using **[run_benchmark.sh](./benchmark/run_benchmark.sh)**

The script support to run TPC-DS, TPC-H and HiBench. If you want to run benchmark by using [OAP](https://github.com/Intel-bigdata/OAP), you should follow the [OAP user guild](https://github.com/Intel-bigdata/OAP/blob/master/docs/OAP-Installation-Guide.md) to configure "/etc/spark/conf/spark-defaults.conf" when running TPC-DS and TPC-H or configure "/opt/software/HiBench/conf/spark.conf" when running HiBench.  

1. For HiBench:
You need to follow the [Hibench Guide](https://github.com/Intel-bigdata/HiBench) to config /opt/software/HiBench/conf/spark.conf and /opt/software/HiBench/conf/hadoop.conf
```  
Generate data: ./run_benchmark.sh -g|--gen   -w|--workload hibench -W|--hibenchWorkload [ml/kmeans|micro/terasort|..] -P|--hibenchProfile [tiny|small|large|huge|gigantic|bigdata] --Port [8020|customed hdfs port]  
Run benchmark: ./run_benchmark.sh -r|--rerun -w|--workload hibench -W|--hibenchWorkload [ml/kmeans|micro/terasort|..] -P|--hibenchProfile [tiny|small|large|huge|gigantic|bigdata] --Port [8020|customed hdfs port]
```
2. For TPC-DS:  
```
Generate data: ./run_benchmark.sh -g|--gen   -w|--workload tpcds -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] -d|--doubleForDecimal -p|--partitionTables --Port [8020|customed hdfs port]   
Run benchmark: ./run_benchmark.sh -r|--rerun -w|--workload tpcds -f|--format [parquet|orc|arrow] -i|--iteration [1|custom the interation you want to run] -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] --Port [8020|customed hdfs port]   
```
3. For TPC-H:  
```
Generate data: ./run_benchmark.sh -g|--gen   -w|--workload tpcds -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] -d|--doubleForDecimal -p|--partitionTables --Port [8020|customed hdfs port]  
Run benchmark: ./run_benchmark.sh -r|--rerun -w|--workload tpch  -f|--format [parquet|orc|arrow] -i|--iteration [1|custom the interation you want to run] -f|--format [parquet|orc] -s|--scaleFactor [10|custom the data scale,the unit is GB] --Port [8020|customed hdfs port] 
``` 
(Note: OAP is installed at "/opt/software/oap"; only enabling native-sql-engine can run TPC-DS or TPC-H with arrow format.)