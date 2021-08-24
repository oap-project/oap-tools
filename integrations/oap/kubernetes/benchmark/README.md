# Run benchmark on Kubernetes

## Configurations
#### Set Spark properties
Go to folder spark/conf/, can set Spark properties in spark-defaults.conf directly.

#### Set S3 access properties
If use AWS S3 as storage, need to add another Hadoop core-site.xml configuration file in spark/conf/, and set S3 access properties.
For example:  

```

<configuration>
  <property>
    <name>fs.s3a.access.key</name>
    <description>AWS access key ID.</description>
    <value>xxxxxx</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <description>AWS secret key.</description>
    <value>xxxxxx</value>
  </property>
  <property>
    <name>fs.s3a.endpoint</name>
    <description>AWS S3 endpoint to connect to. An up-to-date list is
      provided in the AWS Documentation: regions and endpoints. Without this
      property, the standard region (s3.amazonaws.com) is assumed.
    </description>
    <value>s3.us-east-2.amazonaws.com</value>
  </property>
  <property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
    <description>Enable S3 path style access ie disabling the default virtual hosting behaviour.
      Useful for S3A-compliant storage providers as it removes the need to set up DNS for virtual hosting.
    </description>
  </property>
  <property>
    <name>fs.s3a.impl</name>
    <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
    <description>The implementation class of the S3A Filesystem</description>
  </property>
</configuration>

```
## Launch one Spark client pod

Firstly, need launch one Spark client pod. Refer to [Start the Client](../README.md#start-the-client).

## Run TPCDS

### Generate TPCDS data
Go to folder benchmark, open the tpcds_datagen.scala and modify the below variables based on integration environments.  
```
// Modify parameters based on integration environments
val scale = "1"
val format = "parquet"
val storage_path = "s3a://aws-emr-resources-348941870272-us-east-2/eks/"
// "true" means use double type instead of decimal
val useDoubleForDecimal = false
// "true" means generate tables with partions
val partitionTables = true
```

Then execute the following command.
``` 
cat tpcds_datagen.scala | sh ../spark/spark-shell-client.sh --jars /opt/home/tools/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar
``` 

### Run TPCDS benchmark
Go to folder benchmark, open the tpcds_run.scala and modify the below variables based on integration environments.
```
val scale = "1"
val format = "parquet"
val storage_path = "s3a://aws-emr-resources-348941870272-us-east-2/eks/"
// how many times to run the whole set of queries
val iterations = 1
// Seq() == all queries
// Seq("q26-v2.4", "q27-v2.4") // run subset of queries
val query_filter = Seq("q26-v2.4", "q27-v2.4")
```

Then execute the following command.
```
cat tpcds_run.scala | sh ../spark/spark-shell-client.sh --jars /opt/home/tools/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar
```
## Run HiBench 

### Generate HiBench KMeans data
Refer to [Intel MLlib on EMR](../../emr/benchamrk/Intel_MLlib_on_EMR.md) to generate KMeans workload datasets.

### Run HiBench KMeans
Firstly, Determine the following parameters, according to [configured kmeans.conf](../../emr/benchamrk/Intel_MLlib_on_EMR.md#define-the-configurations-of-kmeans.conf) and generated KMeans dataset path.

```
# hibench.kmeans.k
-k 10
# hibench.kmeans.max_iteration
--numIterations 5
# hibench.kmeans.storage.level
--storageLevel MEMORY_ONLY
# hibench.kmeans.initializationmode Random
--initMode Random
# generated KMeans dataset path
s3a://aws-emr-resources-348941870272-us-east-2/datagen/HiBench/Kmeans/Input/3000000/samples

```

Go to folder ../spark. Launch HiBench KMeans Spark job with above parameters.  

```
sh ./spark-submit-client.sh \
  --class com.intel.hibench.sparkbench.ml.DenseKMeans /opt/home/sparkbench-assembly-8.0-SNAPSHOT-dist.jar -k 10 --numIterations 5 --storageLevel MEMORY_ONLY --initMode Random s3a://aws-emr-resources-348941870272-us-east-2/datagen/HiBench/Kmeans/Input/3000000/samples
  
```





