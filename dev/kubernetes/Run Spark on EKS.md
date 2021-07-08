 # Run Spark/OAP on EKS
Before doing this, we assume you have setup EKS cluster and kubectl client tool. All the tool scripts are under "spark" folder. 
We tested these scripts in kubectl client side. 

### Create Spark User and Assign Cluster Role
Spark running on EKS needs edit role of your EKS cluster to create driver or executor pods. 
Go to spark folder and execute the following command to create "spark" user and assign the role. Make sure you have logged in EKS and have administor role of the cluster.
``` 
sh ./spark-kubernetes-prepare.sh
``` 

### Run Spark/OAP Job in Cluster mode
In EKS, you can run Spark/OAP job using spark-submit in Cluster mode at any node which has access to your EKS API server.

#### Run Spark Pi Job
You can run a Spark Pi job for a simple testing of the enironment is working. Pass the EKS API endpoint to the --master parameter. Execute the following command.
For example:
``` 
sh ./spark-pi.sh --master EC3B44F87E0214EF3DC53A17D6B2F4AB.gr7.us-east-2.eks.amazonaws.com  --image oap-centos:1.1.1  --spark_conf ./conf
``` 
#### Run Spark Job through spark-submit
You can submit your own job. Pass the EKS API endpoint to the --master parameter. Execute the following command.
For exmaple:
``` 
sh ./spark-submit.sh --master EC3B44F87E0214EF3DC53A17D6B2F4AB.gr7.us-east-2.eks.amazonaws.com  --image oap-centos:1.1.1  --spark_conf ./conf --name spark-pi --class org.apache.spark.examples.SparkPi  local:///opt/home/spark-3.1.1/examples/jars/spark-examples_2.12-3.1.1.jar 100
``` 

### Run Spark/OAP in Client Mode
A lot of Spark tools run at Client Mode, such Spark Thrift Server, Spark Shell and Spark SQL. Spark Submit can also run at Client Mode.

#### Spark Thrift Server

##### Start Spark Thrift Server
Execute the following command to start Spark Thrift Server in a pod and launch corresponding services.
For example:
``` 
sh ./spark-thrift-server-eks.sh start --image oap-centos:1.1.1  --spark_conf ./conf
``` 

##### Stop Spark Thrift Server
Execute the following command to stop Spark Thrift Server in a pod and stop corresponding services.
``` 
sh ./spark-thrift-server-eks.sh stop
``` 
##### Connect beeline to Spark Thrift Server
Get the Thrift Server LoadBalancer address EXTERNAL-IP
```
$ kubectl get service spark-thrift-server-loadbalancer-service
NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)           AGE
spark-thrift-server-loadbalancer-service   LoadBalancer   10.100.173.81   a49a78edc97024147a4ed59bdfcad0b5-2085994748.us-east-2.elb.amazonaws.com   30000:30333/TCP   33m
```


Execute the following command to connect to the Thrift server. Make sure you execute it on one of your EKS cluster node.
``` 
sh ./spark-beeline.sh --master a49a78edc97024147a4ed59bdfcad0b5-2085994748.us-east-2.elb.amazonaws.com
``` 

##### Launch a Shell to Spark Thrift Server
Execute the following command to launch a command shell to the server.
``` 
sh ./spark-thrift-server-eks.sh client
``` 

#### Run Other Spark Client Mode Tools
To run Spark Shell, Spark SQL or Spark Submit at client mode, we need to launch a client pod and then run correponding tool in the pod.

##### Start the Client
Execute the following command to configure and start the client pod.
For example:
``` 
sh ./spark-client.sh start --image oap-centos:1.1.1 --spark_conf ./conf
``` 

##### Run Spark Shell
After you have started the client pod, you can execute the following command to start the Spark shell into the pod:
For example:
``` 
sh ./spark-shell-client.sh --conf spark.executor.instances=1
``` 

##### Run Spark SQL
After you have started the client pod, you can execute the following command to start the Spark SQL into the pod:
For example:
``` 
sh ./spark-sql-client.sh --conf spark.executor.instances=1
``` 

##### Run Spark Submit
After you have started the client pod, you can execute the following command to start the Spark Submit into the pod.
For example:
``` 
sh ./spark-submit-client.sh --conf spark.executor.instances=1 --name spark-pi --class org.apache.spark.examples.SparkPi  local:///opt/home/spark-3.1.1/examples/jars/spark-examples_2.12-3.1.1.jar 100
``` 

##### Stop the Client
If you have completed all your work, execute the following command to stop the client pod.
``` 
sh ./spark-client.sh stop
``` 

#### Run OAP components in Client Mode

##### Start the Client pod
Just refer to [Start the Client](#start-the-client).

##### Run Kmeans example with OAP MLlib
After you have started the client pod, you can execute the following command to start the Spark shell into the pod:
For example:

Go to folder oap
``` 
cat Kmeans-example.scala | sh spark-shell-mllib.sh
``` 

##### Run example with Native SQL Engine
After you have started the client pod, you can execute the following command to start the Spark shell into the pod:
For example:

Go to folder oap
``` 
cat Native-SQL-Engine-example.scala | sh ./spark-shell-native-sql-engine.sh
``` 

##### Stop the Client pod
Just refer to [Stop the Client](#stop-the-client).

