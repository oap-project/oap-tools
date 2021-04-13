# Use Intel Optimized ML libraries in Databricks Runtime for ML
This directory contains scripts useful to create clusters with intel optimized AI libraries on Databricks.

## 1. Upload init script 

Upload the init script **[init_intel_optimized_ml.sh](./init_intel_optimized_ml.sh)** to Databricks DBFS:
    
- Download **[init_intel_optimized_ml.sh](./init_intel_optimized_ml.sh)**.
- Click Data Icon in the sidebar.
- Click the DBFS button at the top of the page.
- Click the Upload button at the top of the page.
- On the Upload Data to DBFS dialog, optionally select a target directory or enter a new one.
- In the Files box, drag and drop or use the file browser to select the file **[init_intel_optimized_ml.sh](./init_intel_optimized_ml.sh)** to upload.
![upload_init_script](./imgs/upload_init_script.png)


## 2. Create a new cluster using init scripts
To use the cluster configuration page to configure a cluster to run an init script:

1. On the cluster configuration page, click the Advanced Options toggle.
2. At the bottom of the page, click the Init Scripts tab.
3. In the Destination drop-down, select a destination type. In the example in the preceding section, the destination is DBFS.
4. Specify a path to the init script. In the example in the preceding section, the path is **dbfs:/FileStore/init_intel_optimized_ml.sh**. The path must begin with dbfs:/.
5. Click Add.
![create_cluster](./imgs/create_cluster.png)