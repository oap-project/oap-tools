# Run benchmark notebooks for performance comparisons

###  Import the notebooks
You should import the **notebook**  we provided to Workspace to run benchmark notebooks.

1. Download the corresponding notebooks: **[benchmark_tensorflow_bertlarge.ipynb](./benchmark_tensorflow_bertlarge.ipynb)** for TensorFlow and **[benchmark_sklearn.ipynb](./benchmark_sklearn.ipynb)** for Scikit-learn to your local folder.
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
   
#### Run benchmark_tensorflow_bertlarge notebook
 1. Create cluster with Databricks ML Runtime or Databricks ML Runtime with Intel Optimized ML libraries as described above. For the Node type, we recommend to use **Standard_F32s_v2**.
 2. Open the notebook *benchmark_tensorflow_bertlarge* and attached it to the corresponding cluster you created.
 3. Run ***Part 1. Download datasets, checkpoints and pre-trained model*** for downloading datasets, checkpoints and pre-trained model.
 4. Run BERT-Large benchmark workload.
 - Run ***Part 2. Run BERT-Large training workload*** for running training workload.
 - Run ***Part 3. Run BERT-Large inference workload*** for running inference workload.
