# OAP MLlib on GCP Dataproc 2.0

## 1. Creating a cluster on Dataproc

### 1.1 Uploading initialization actions

Upload the initialization actions scripts to Cloud Storage bucket. 
**[bootstrap_oap.sh](../bootstrap_oap.sh)** is to help conda install OAP packages and
**[bootstrap_benchmark.sh](./bootstrap_benchmark.sh)** is to help install necessary tools for TPC-DS, TPC-H and HIBench on Dataproc clusters.
    
1). Download **[bootstrap_oap.sh](../bootstrap_oap.sh)** and **[bootstrap_benchmark.sh](./bootstrap_benchmark.sh)** to a local folder.

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


## 2. Using benchmark-tools to easily run K-means, PCA and ALS with OAP MLlib

Run below the command to change the owner of directory`/opt/benchmark-tools`:

```
sudo chown $(whoami):$(whoami) -R /opt/benchmark-tools
```

Modify `/opt/benchmark-tools/HiBench/conf/hadoop.conf`:
```
hibench.hadoop.home               /usr/lib/hadoop/
```


### 2.1. Update the basic configuration of Spark

#### Update the basic configuration of Spark

```
git clone https://github.com/oap-project/oap-tools.git
cd oap-tools/integrations/oap/benchmark-tool
sudo cp /lib/spark/conf/spark-defaults.conf ./repo/confs/spark-oap-dataproc/hibench/spark.conf;
```

### 2.2. Create the testing repo && Config OAP-MLlib

#### Create the testing repo
```
mkdir ./repo/confs/OAP_MLlib_performance
```
#### Update the content of .base to inherit the configuration of ./repo/confs/spark-oap-dataproc
```
echo "../spark-oap-dataproc" > ./repo/confs/OAP_MLlib_performance/.base
```
#### Update the content of ./repo/confs/OAP_MLlib_performance/env.conf
```
STORAGE=s3
BUCKET={bucket_name}
```
Note: If you want to use s3 for storage, you must define BUCKET; if you use hdfs for storage, you should set STORAGE like ```STORAGE=hdfs```

#### Update the configurations of Spark

**[bootstrap_oap.sh](../bootstrap_oap.sh)** will help install all OAP packages under dir `/opt/benchmark-tools/oap`,
make sure to add below configuration to `./repo/confs/OAP_MLlib_performance/hibench/spark.conf`.

```
spark.files                       /opt/benchmark-tools/oap/oap_jars/oap-mllib-1.2.0.jar
spark.executor.extraClassPath     ./oap-mllib-1.2.0.jar
spark.driver.extraClassPath       /opt/benchmark-tools/oap/oap_jars/oap-mllib-1.2.0.jar

# Make it enough to cache training data
spark.executor.memoryOverhead               512m   
# Refer to the default value of spark.executor.cores of /lib/spark/conf/spark-defaults.conf  
hibench.yarn.executor.num                   2 
# Divide the sum of vcores by hibench.yarn.executor.num       
hibench.yarn.executor.cores                 2        
# Equal to the sum of vcores
spark.default.parallelism                   4        
 # Equal to the sum of vcores
spark.sql.shuffle.partitions                4       
```


#### Define te the configurations of hibench.conf

Edit the content of `./repo/confs/OAP_MLlib_performance/hibench/hibench.conf` to change the 
```
# Support tiny, small, large, huge, gigantic, bigdata.
hibench.scale.profile                       tiny     
```

#### Define the configurations of kmeans.conf

Edit the content of `./repo/confs/OAP_MLlib_performance/hibench/kmeans.conf`
```
hibench.kmeans.tiny.num_of_clusters         5
hibench.kmeans.tiny.dimensions              3
hibench.kmeans.tiny.num_of_samples          30000
hibench.kmeans.tiny.samples_per_inputfile   6000
hibench.kmeans.tiny.max_iteration           5
hibench.kmeans.tiny.k                       10
hibench.kmeans.tiny.convergedist            0.5
```
Note: You can use default value of kmeans.conf and no need to change any values. If you want to change the parameters of K-means, you need to modify the value of the corresponding scale profile.

#### Define the configurations of pca.conf

Edit the content of `./repo/confs/OAP_MLlib_performance/hibench/pca.conf`
```
hibench.pca.tiny.examples                   10
hibench.pca.tiny.features                   10
hibench.pca.tiny.k                          3
hibench.pca.tiny.maxresultsize              "1g"
```
Note: You can use default value of pca.conf and no need to change any values. If you want to change the parameters of PCA, you need to modify the value of the corresponding scale profile.

#### Define the configurations of als.conf

Edit the content of `./repo/confs/OAP_MLlib_performance/hibench/pca.conf`
```
hibench.als.tiny.users                     100
hibench.als.tiny.products                  100
hibench.als.tiny.ratings                   200
hibench.als.tiny.implicitprefs	           true
```
Note: You can use default value of als.conf and no need to change any values. If you want to change the parameters of ALS, you need to modify the value of the corresponding scale profile.

### 2.3. Run K-means

```
### Update: 

bash bin/hibench.sh update ./repo/confs/OAP_MLlib_performance   

### Generate data:
 
bash bin/hibench.sh gen_data ./repo/confs/OAP_MLlib_performance ml/kmeans

### Run benchmark: 

bash bin/hibench.sh run ./repo/confs/OAP_MLlib_performance ml/kmeans
```

### 2.4. Run PCA:  

```
### Update: 
bash bin/hibench.sh update ./repo/confs/OAP_MLlib_performance   

### Generate data: 

bash bin/hibench.sh gen_data ./repo/confs/OAP_MLlib_performance ml/pca

### Run benchmark: 

bash bin/hibench.sh run ./repo/confs/OAP_MLlib_performance ml/pca
```

### 2.4. Run ALS:  

```
### Update: 

bash bin/hibench.sh update ./repo/confs/OAP_MLlib_performance   

### Generate data: 

bash bin/hibench.sh gen_data ./repo/confs/OAP_MLlib_performance ml/als

### Run benchmark: 

bash bin/hibench.sh run ./repo/confs/OAP_MLlib_performance ml/als
```

