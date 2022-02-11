# OAP MLlib on GCP Dataproc 2.0

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

2). **Set up cluster:** choose cluster type and Dataproc image version `2.0-debian10`, enable component gateway, and add Jupyter Notebook, ZooKeeper.

![Enable_component_gateway](../imgs/component_gateway_debian.png)

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

Modify `/opt/benchmark-tools/HiBench/conf/hadoop.conf`, if you choose GCS,change the below item:
```
hibench.hdfs.master           gs://<your_bucket>/
```


### 2.1. Update the basic configuration of Spark

#### Update the basic configuration of Spark

```
git clone https://github.com/oap-project/oap-tools.git
cd oap-tools/integrations/oap/benchmark-tool
sudo cp /etc/spark/conf/spark-defaults.conf ./repo/confs/spark-oap-dataproc/hibench/spark.conf
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
#### Update the content of `./repo/confs/OAP_MLlib_performance/env.conf`
```
STORAGE=gs
BUCKET={bucket_name}
```
Note: If you want to use GCS for storage, you must define BUCKET; if you use HDFS for storage, you should only set STORAGE like ```STORAGE=hdfs```

#### Update the configurations of Spark

**[bootstrap_oap.sh](../bootstrap_oap.sh)** will help install all OAP packages under dir `/opt/benchmark-tools/oap`.

```
mkdir -p ./repo/confs/OAP_MLlib_performance/hibench
vim ./repo/confs/OAP_MLlib_performance/hibench/spark.conf
```
Add below configuration to `./repo/confs/OAP_MLlib_performance/hibench/spark.conf`.

```
spark.files                       /opt/benchmark-tools/oap/oap_jars/oap-mllib-1.3.0.jar
spark.executor.extraClassPath     ./oap-mllib-1.3.0.jar
spark.driver.extraClassPath       /opt/benchmark-tools/oap/oap_jars/oap-mllib-1.3.0.jar

# Make it enough to cache training data
spark.executor.memoryOverhead               512m   
# Refer to the default value of spark.executor.cores of /etc/spark/conf/spark-defaults.conf  
hibench.yarn.executor.num                   2 
# Divide the sum of vcores by hibench.yarn.executor.num       
hibench.yarn.executor.cores                 2        
# Equal to the sum of vcores
spark.default.parallelism                   4        
# Equal to the sum of vcores
spark.sql.shuffle.partitions                4       
```

**Note:** OAP MLlib adopted oneDAL as implementation backend. oneDAL requires enough native memory allocated for each executor. For large dataset, depending on algorithms, you may need to tune `spark.executor.memoryOverhead` to allocate enough native memory. 
Setting this value to larger than __dataset size / executor number__ is a good starting point.

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

Edit the content of `./repo/confs/OAP_MLlib_performance/hibench/als.conf`
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

### 2.5 OAP MLlib integration verification

When you run test above, you can check OAP MLlib integration verification from Spark WebUI jobs name containing "DAL" as below.

![OAP MLlib integration](../imgs/mllib_integration.png)


## 3. Using benchmark-tools to run bigdata workflow with OAP MLlib

### 3.1 Prepare workflow

There is one repo `./repo/workflows/oap_release_performance_test_on_Dataproc` which provides default configuration for OAP MLLib **bigdata** hibench profile workflow. 

Here we choose the **n2-standard-80** instances to create a cluster (1 master + 3 workers) and each instance has 80 vCPUs and 320GB memory. 

Let's take this cluster for example, we have already helped you create corresponding repo under `./repo/workflows/` which is `./repo/workflows/OAP_Mllib_on_N2_performance` if you also want to quickly trigger workflow to check OAP MLlib performance gain with the same cluster. 

#### Configuration for OAP MLlib on n2-standard-80 cluster

We inherit configuration from `./repo/workflows/oap_release_performance_test_on_Dataproc`.
Then the following configuration is already set for `./repo/workflows/OAP_Mllib_on_N2_performance`.

##### hibench.conf

```
hibench.scale.profile                bigdata
```

##### kmeans.conf

```
hibench.kmeans.bigdata.num_of_clusters          5
hibench.kmeans.bigdata.dimensions               1000
hibench.kmeans.bigdata.num_of_samples           25000000
hibench.kmeans.bigdata.samples_per_inputfile    10000
hibench.kmeans.bigdata.k                        300
hibench.kmeans.bigdata.max_iteration            40
hibench.kmeans.storage.level                    MEMORY_ONLY
```

##### pca.conf

```
hibench.pca.bigdata.examples            800000
hibench.pca.bigdata.features            5000
hibench.pca.bigdata.k                   50
hibench.pca.bigdata.maxresultsize       "8g"
```

##### als.conf

```
hibench.als.bigdata.users               4000000
hibench.als.bigdata.products            1000000
hibench.als.bigdata.ratings             100000000
hibench.als.bigdata.implicitprefs       true
hibench.als.rank                        50
hibench.als.numIterations               10
hibench.als.Lambda                      0.1
```

As for `spark.conf`, according to the current 1master+3workers **n2-standard-80** cluster, we also have already set it in `./repo/workflows/oap_release_performance_test_on_Dataproc`

##### spark.conf

```
hibench.yarn.executor.num     18
hibench.yarn.executor.cores   6

spark.executor.memory         36g
spark.executor.memoryOverhead 6g
spark.driver.memory           100g

spark.default.parallelism     120
spark.sql.shuffle.partitions  120

```

**Note:** OAP MLlib adopted oneDAL as implementation backend. oneDAL requires enough native memory allocated for each executor. For large dataset, depending on algorithms, you may need to tune `spark.executor.memoryOverhead` to allocate enough native memory. 
          Setting this value to larger than __dataset size / executor number__ is a good starting point. So here for **bigdata** Hibench data profile, we set 
          `spark.executor.memoryOverhead` to `6g`. Other Spark configuration is set according to cluster resources.

Configuration above already set for `./repo/workflows/OAP_Mllib_on_N2_performance`, so you needn't modify anything.

Now, you only need follow the 2 steps below to enable workflow.

Step 1. We already set `spark.history.fs.logDirectory`  to  `hdfs:///var/log/spark/apps`, so then please create a directory on HDFS as below.

```
hadoop fs -mkdir -p /var/log/spark/apps
```

Step 2. Modify items of `./repo/workflows/OAP_Mllib_on_N2_performance/common/env.conf` for the cluster.

```
STORAGE=gs
BUCKET={your_bucket_name}
BASELINE_COMP=TRUE
```

### 3.2 Run OAP MLlib performance test

Run the following command to trigger OAP MLlib workflow including ALS on 5GB data scale, Kmeans on 250GB data scale and PCA on 30GB data scale.

```
python2 ./bin/run_workflows.py --workflows ./repo/workflows/OAP_Mllib_on_N2_performance
```

After test, there will be a `output_workflow` directory under `./repo/workflows/OAP_Mllib_on_N2_performance/output/`. Please open the `baseline-summary.html` on browser, 
you will get OAP MLlib performance comparison with baseline which is vanilla Spark MLlib on Dataproc.

NOTE: Please ignore the current email sending issues.

![performance summary](../imgs/mllib_performance_summary.png)

### 3.3 Run OAP MLlib performance test on other Dataproc clusters

We choose the **n2-standard-80** instances to create a cluster (1 master + 3 workers) as an example, which is shown above.

You certainly could create other type clusters, the easy way to quickly set up a workflow repo is to just 

1). Modify **all** the `spark.conf` under `./repo/workflows/OAP_Mllib_on_N2_performance/components`, set corresponding items according your cluster resources.

2). Modify the `./repo/workflows/OAP_Mllib_on_N2_performance/common/env.conf`, such as replacing with your gs bucket name.

3). Run `hadoop fs -mkdir -p /var/log/spark/apps`
     
Then, run command below to trigger workflow test just as above.

 ```
 python2 ./bin/run_workflows.py --workflows ./repo/workflows/OAP_Mllib_on_N2_performance
 ```
