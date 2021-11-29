# Use OAP on Azure Databricks cloud



## 1. Upload init script 

Upload the init script **[init_oap.sh](./init_oap.sh)** to Databricks DBFS:
    
1. Download **[init_oap.sh](./init_oap.sh)** to a local folder.
2. Click **Data** icon in the left sidebar.
3. Click the **DBFS** button and then **Upload** button at the top.
4. Select a target directory, for example, FileStore, in the **Upload Data to DBFS** dialog.
5. Browse to the file **[init_oap.sh](./init_oap.sh)** in the local folder to upload in the Files box.

![upload_init_script](../../ml/databricks/imgs/upload_init_script.png)


## 2. Create a new cluster using init script
To create a new cluster using the uploaded init script, follow the following steps:

1. Click the  **Clusters** icon in the left sidebar.
2. Choose the Cluster Mode and Databricks Runtim Version.
3. Click the **Advanced Options** toggle on the cluster configuration page,
4. Click the **Init Scripts** tab at the bottom of the page.
5. Select the "DBFS" destination type in the **Destination** drop-down.
6. Specify a path to the init script. In the example in the preceding section, the path is **dbfs:/FileStore/init_oap.sh**. The path must begin with dbfs:/.
7. Click **Add**. 
8. Add Spark config in **Advanced Options**, for example:
```
spark.files                       /databricks/conda/oap_jars/oap-mllib-1.2.0.jar
spark.executor.extraClassPath     /databricks/conda/oap_jars/oap-mllib-1.2.0.jar
spark.driver.extraClassPath       /databricks/conda/oap_jars/oap-mllib-1.2.0.jar
```

![create_cluster](./imgs/create-oap-cluster.png)


