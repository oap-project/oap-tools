# Use Plasma SQL DS CACHE 
### 1. Prepare yaml file for Plasma Store Server POD
```
// plasma-store-server.yaml 
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: plasma-store-server
  namespace: default
  labels:
    k8s-app: oap-cache-backend
spec:
  selector:
    matchLabels:
      name: pmem
  template:
    metadata:
      labels:
        name: pmem
    spec:
      containers:
      - name: plasma-store-server
        image: $CONTAINER_IMAGE 
        imagePullPolicy: IfNotPresent
        command: ["/bin/sh"]
        # /var/log/plasmaStore is the Unix Socket for future connection, set it as value of spark.sql.oap.external.cache.socket.path in Spark conf
        args: ["-c", "export LD_LIBRARY_PATH=$OAP_DIR/lib:$LD_LIBRARY_PATH; echo $LD_LIBRARY_PATH; $OAP_DIR/bin/plasma-store-server -m $PMEM_SIZE -d $PMEM_PATH -s /var/log/plasmaStore;"]
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varservice
          mountPath: /var/log
        - name: pmem
          mountPath: /mnt/pmem
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varservice
        hostPath:
          # Path to store the Unix Socket file that plasma-store-server generates, make sure all Spark executors pods can access to this path
          path: /var/log
      - name: pmem
        hostPath:
          # Path to PMem that plasma-store-server will launch on
          path: /mnt/pmem

```

### 2. Spark Configuration
Update spark conf(integrations/oap/kubernetes/spark/conf/spark-default.conf) to use Plasma cache backend
```
#OAP: libraries to load
spark.executorEnv.LD_LIBRARY_PATH /opt/home/conda/envs/oap-1.2.0/lib/
spark.executor.extraLibraryPath /opt/home/conda/envs/oap-1.2.0/lib/
spark.driver.extraLibraryPath /opt/home/conda/envs/oap-1.2.0/lib/

#OAP: extra jars to include
spark.sql.extensions    org.apache.spark.sql.OapExtensions
spark.executor.extraClassPath    /opt/home/conda/envs/oap-1.2.0/oap_jars/plasma-sql-ds-cache-1.2.0-snapshot-with-spark-3.1.1.jar:/opt/home/conda/envs/oap-1.2.0/oap_jars/pmem-common-1.2.0-snapshot-with-spark-3.1.1.jar:/opt/home/conda/envs/oap-1.2.0/oap_jars/arrow-plasma-4.0.0.jar
spark.driver.extraClassPath    /opt/home/conda/envs/oap-1.2.0/oap_jars/plasma-sql-ds-cache-1.2.0-snapshot-with-spark-3.1.1.jar:/opt/home/conda/envs/oap-1.2.0/oap_jars/pmem-common-1.2.0-snapshot-with-spark-3.1.1.jar:/opt/home/conda/envs/oap-1.2.0/oap_jars/arrow-plasma-4.0.0.jar

# for parquet file format, enable binary cache
spark.sql.oap.parquet.binary.cache.enabled                   true
# for ORC file format, enable binary cache
spark.sql.oap.orc.binary.cache.enabled                       true
# enable external cache strategy
spark.oap.cache.strategy                                     external
spark.sql.oap.dcpmm.free.wait.threshold                      50000000000
# according to your executor core number
spark.executor.sql.oap.cache.external.client.pool.size       10

#OAP: volumns for Spark
spark.kubernetes.executor.volumes.hostPath.pmem-cache.mount.path /var/log
spark.kubernetes.executor.volumes.hostPath.pmem-cache.mount.readOnly false
spark.kubernetes.executor.volumes.hostPath.pmem-cache.options.path /var/log
spark.kubernetes.executor.volumes.hostPath.pmem-cache.options.type Directory

spark.eventLog.enabled           true
spark.eventLog.dir   /var/log

spark.sql.oap.external.cache.socket.path /var/log/plasmaStore
```

### 3. Validation steps

Go to folder integrations/oap/kubernetes/spark/ and do following steps:
``` 
# Start spark client
sh ./spark-client.sh start --image oap-ubuntu:1.3.1 --spark_conf ./conf
# Start spark shell
sh ./spark-shell-client.sh --conf spark.executor.instances=1
# Launch plasma-store-server:
export OAP_DIR=/opt/home/conda/envs/oap-1.2.0
export PMEM_PATH=/mnt/pmem
export PMEM_SIZE=5000000000
export CONTAINER_IMAGE=oap-ubuntu:1.3.1
envsubst < plasma-store-server.yaml | kubectl apply -f -
# use following scala to trigger cache
spark.sql(s"""CREATE TABLE oap_test(a INT, b STRING) USING parquet OPTIONS(path '/var/log/test')""".stripMargin)
val data = (1 to 30000).map { i => (i, s"this is test $i") }.toDF().createOrReplaceTempView("t")
spark.sql("insert overwrite table oap_test select * from t")
spark.sql("select * from oap_test").show()
// verify cache
spark.sql("select * from oap_test").show()
# forward 4040 port for Spark UI access
kubectl port-forward spark-client 4040:4040
``` 

Then goto localhost:4040 and check cache statistics, shown as following:
```
D	Address	Status	Storage Memory	Total Cache Size/Count	Data & Index Cache Size/Count	Data Cache Size/Count	Index Cache Size/Count	Unreleased Cache Size/Count	Hit Rate (hit/miss)
1	192.244.1.37:41465	Active	136.1K / 23.8G	33.3K / 2	33.3K / 2	33.3K / 2	0 / 0	0 / 0	50.00% (2/2)
```

