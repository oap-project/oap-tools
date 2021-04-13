# Use notebook to run scikit-learn_bench and Bert benchmark on Databricks 

##  Import the notebooks
You can import the **notebook**  we provided from a URL or a file.

1. Download the notebooks **[Bert-Benchmark-Tensorflow.ipynb](./Bert-Benchmark-Tensorflow.ipynb)** and **[Skl-Bench-Run.ipynb](./Skl-Bench-Run.ipynb)**
2. Click the  Workspace Icon or the  Home Icon in the sidebar. Do one of the following:

- Next to any folder, click the Menu Dropdown on the right side of the text and select Import.

- In the Workspace or a user folder, click Down Caret and select Import.
![IMPORT-NOTEBOOK](../imgs/import-notebook.png)
Import notebook
3. Specify the URL or browse to a file containing a supported external format.

4. Click Import.

## Create clusters with Docker Container use Intel Optimized ML Libryries.
1.  Click the  clusters Icon
2.  Specify the cluster name 
3.  Choose the Cluster Mode **Single Node** and Databricks Runtime Version **Runtime: 7.4**
4.  Select Use your own Docker container
- In the Docker Image URL field, enter **jerrychenhf/intel-scikit-learn:databricks-3.0**
- Select the authentication type **Default**
5. Choose the Node type, we recommend **Standard_F16s_v2** and **Standard_F32s_v2**

6. Open the notebook and attached it to the cluster you created, then run it.
![create_cluster_with_container](../imgs/create_cluster_with_container.png)

## Create a new cluster using init_intel_optimized_ml.sh

You can refer to the guide [Use Intel Optimized ML libraries in Databricks Runtime for ML](../README.md)


## Notes


For best performance of Bert benchmark, use the same value for the arguments num-cores and num-intra-thread in the notebook **[Bert-Benchmark-Tensorflow.ipynb](./Bert-Benchmark-Tensorflow.ipynb)**, **num-cores**  is equal to the number of  ***Core(s) per socket***, you can use the command **"lscpu"** to get it.

