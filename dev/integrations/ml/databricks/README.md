# Use Intel Optimized ML libraries on Azure Databricks cloud with Databricks Runtime 7.5 ML 
This document is used to guide the steps of creating clusters with intel optimized AI libraries on Databricks.

## 1. Upload init script 

Upload the init script **[init_intel_optimized_ml.sh](./init_intel_optimized_ml.sh)** to Databricks DBFS:
    
- Download **[init_intel_optimized_ml.sh](./init_intel_optimized_ml.sh)**.
- Click **Data** icon in the sidebar.
- Click the **DBFS** button at the top of the page.
- Click the **Upload** button at the top of the page.
- On the **Upload Data to DBFS** dialog, optionally select a target directory or enter a new one.
- In the Files box, drag and drop or use the file browser to select the file **[init_intel_optimized_ml.sh](./init_intel_optimized_ml.sh)** to upload. 

![upload_init_script](./imgs/upload_init_script.png)


## 2. Create a new cluster using init scripts
To use the cluster configuration page to configure a cluster to run an init script:



1. Click the  **Clusters** icon in the sidebar.
2. Choose the Cluster Mode **Single Node** and Databricks Runtim Version **Runtime:7.5 ML**.
3. On the cluster configuration page, click the **Advanced Options** toggle.
4. At the bottom of the page, click the **Init Scripts** tab.
5. In the **Destination** drop-down, select a destination type. In the example in the preceding section, the destination is DBFS.
6. Specify a path to the init script. In the example in the preceding section, the path is **dbfs:/FileStore/init_intel_optimized_ml.sh**. The path must begin with dbfs:/.
7. Click **Add**. 

![create_cluster](./imgs/create_cluster.png)


## 3. Run benchmark notebooks for performance comparison

###  Import the notebooks
You should import the **notebook**  we provided from firstly.

1. Download the notebooks **[benchmark_tensorflow.ipynb](./notebooks/benchmark_tensorflow.ipynb)** and **[benchmark_sklearn.ipynb](./notebooks/benchmark_sklearn.ipynb)**.
2. Click the  **Workspace** Icon or the  **Home** Icon in the sidebar. Do one of the following:
   - Next to any folder, click the **Menu** Dropdown on the right side of the text and select Import.

   - In the Workspace or a user folder, click **Down** caret and select Import. 

   - Import notebook.  
 ![IMPORT-NOTEBOOK](./imgs/import-notebook.png)
3. Browse to the notebooks file.

4. Click **Import**.


### Run benchmark by notebook
#### Run benchmark_sklearn
 1. Create clusters with Databricks ML Runtime or with intel optimized AI libraries, for the Node type, we recommend **Standard_F16s_v2** and **Standard_F32s_v2**.
 2. Open the notebook *benchmark_sklearn* and attached it to the cluster you created, then run it.
   
#### Run benchmark_tensorflow
  The steps to run benchmark_tensorflow are same to [Run benchmark_sklearn](#run-benchmark_sklearn).   

  ***Notice:*** For best performance of Bert benchmark, use the same value for the arguments num-cores and num-intra-thread in the notebook **[benchmark_tensorflow.ipynb](./notebooks/benchmark_tensorflow.ipynb)**, **num-cores**  is equal to the number of  ***Core(s) per socket***, you can use the command **"lscpu"** to get it.