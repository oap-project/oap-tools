 # Run Spark/OAP on GKE
Before doing this, we assume you have setup GKE cluster and kubectl client tool. All the tool scripts are under "../spark" or "../oap" folder. 
We tested these scripts in Cloud Shell. 

Generally, you can follow the [Run Spark/OAP on Kubernetes](../README.md#run-sparkoap-on-kubernetes) directly, except for the below:

## Use GKE API endpoint
When use scripts needing to pass server endpoint to the --master parameter, just use GKE API endpoint. For example:
```
sh ./spark-pi.sh --master 34.66.125.2  --image oap-ubuntu:1.2.0  --spark_conf ./conf
```

## Set GCS access properties
If use GCS as storage, need to add another Hadoop core-site.xml configuration file in spark/conf/, and set GCS access properties.
For example:

```
<configuration>
     <property>
            <name>fs.gs.impl</name>
            <value>com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem</value>
            <description>The FileSystem for gs: (GCS) uris.</description>
    </property>
    <property>
            <name>fs.AbstractFileSystem.gs.impl</name>
            <value>com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS</value>
            <description>The AbstractFileSystem for gs: (GCS) uris.</description>
    </property>
</configuration>
```


## Use GKE LoadBalancer
In GKE environment, we use the GKE LoadBalancer to expose one service.

Unlike [Start Spark Thrift Server on Kubernetes](../README.md#start-spark-thrift-server), you need to add the --engine loadbalancer, then the script can use the GKE LoadBalancer service instead of the Kubernetes NodePort service automatically.
For example:
``` 
sh ./spark-thrift-server.sh start --image oap-ubuntu:1.2.0 --engine loadbalancer  --spark_conf ./conf
```

Then, get the Thrift server LoadBalancer address EXTERNAL-IP with the following command.
```
$ kubectl get service spark-thrift-server-loadbalancer-service
NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
spark-thrift-server-loadbalancer-service   LoadBalancer   10.83.255.116   34.70.114.1   30000:31089/TCP   53s
```

Finally, when using beeline tool to connect to the Thrift server, just pass the LoadBalancer address EXTERNAL-IP to the --master parameter in spark-beeline.sh. 
``` 
sh ./spark-beeline.sh --master 34.70.114.1
``` 



