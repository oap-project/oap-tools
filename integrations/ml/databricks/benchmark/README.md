# Run benchmark notebooks for performance comparisons

###  Import the notebooks
You should import the **notebook**  we provided to Workspace to run benchmark notebooks.

1. Download the notebooks **[benchmark_tensorflow_preparation.ipynb](./benchmark_tensorflow_preparation.ipynb)**, **[benchmark_tensorflow_bertlarge.ipynb](./benchmark_tensorflow_bertlarge.ipynb)** and **[benchmark_sklearn.ipynb](./benchmark_sklearn.ipynb)** to your local folder.
2. Click the  **Workspace** icon or the  **Home** icon in the left sidebar.
3. Click **Down** caret in the Workspace or a user folder and select Import. 

![import-notebook](../imgs/import-notebook.png)

4. Browse to the notebook files downloaded to the local folder.
5. Click **Import**.


### Run benchmark notebooks
#### Run benchmark_sklearn notebook
 1. Create cluster with Databricks ML Runtime or Databricks ML Runtime with Intel Optimized ML libraries as described above. For the Node type, we recommend to use **Standard_F16s_v2** or **Standard_F32s_v2**.
 2. Open the notebook *benchmark_sklearn* and attach it to the corresponding cluster you created.
 3. Click **Run All**.
   
#### Run benchmark_tensorflow_preparation and benchmark_tensorflow_bertlarge notebook
 1. Create cluster with Databricks ML Runtime or Databricks ML Runtime with Intel Optimized ML libraries as described above. For the Node type, we recommend to use **Standard_F32s_v2**.
 2. Open the notebook *benchmark_tensorflow_preparation* and *benchmark_tensorflow_bertlarge*, then attach them to the corresponding cluster you created.
 3. Run *benchmark_tensorflow_preparation* for downloading datasets, checkpoints and models.
 4. Run *benchmark_tensorflow_bertlarge* for running training and inference workload.
