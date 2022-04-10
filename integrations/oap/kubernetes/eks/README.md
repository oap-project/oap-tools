 # Run Spark/OAP on EKS
Before doing this, we assume you have setup EKS cluster and kubectl client tool. All the tool scripts are under "../spark" or "../oap" folder. 
We tested these scripts in kubectl client side. 

Generally, you can follow the [Run Spark/OAP on Kubernetes](../README.md#run-sparkoap-on-kubernetes) directly, except for the below:

## Use EKS API endpoint
When use scripts needing to pass server endpoint to the --master parameter, just use EKS API endpoint. For example:
```
sh ./spark-pi.sh --master EC3B44F87E0214EF3DC53A17D6B2F4AB.gr7.us-east-2.eks.amazonaws.com  --image oap-ubuntu:1.3.1  --spark_conf ./conf
```

## Use EKS LoadBalancer
In EKS environment, we use the EKS LoadBalancer to expose one service.

Unlike [Start Spark Thrift Server on Kubernetes](../README.md#start-spark-thrift-server), you need to add the --engine loadbalancer, then the script can use the EKS LoadBalancer service instead of the Kubernetes NodePort service automatically.
For example:
``` 
sh ./spark-thrift-server.sh start --image oap-ubuntu:1.3.1 --engine loadbalancer  --spark_conf ./conf
```

Then, get the Thrift server LoadBalancer address EXTERNAL-IP with the following command.
```
$ kubectl get service spark-thrift-server-loadbalancer-service
NAME                                       TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)           AGE
spark-thrift-server-loadbalancer-service   LoadBalancer   10.100.173.81   a49a78edc97024147a4ed59bdfcad0b5-2085994748.us-east-2.elb.amazonaws.com   30000:30333/TCP   33m
```

Finally, when using beeline tool to connect to the Thrift server, just pass the LoadBalancer address EXTERNAL-IP to the --master parameter in spark-beeline.sh. 
``` 
sh ./spark-beeline.sh --master a49a78edc97024147a4ed59bdfcad0b5-2085994748.us-east-2.elb.amazonaws.com
``` 



