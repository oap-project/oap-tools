# Run benchmark notebooks for performance

###  Import the notebooks
You should import the **notebook**  we provided to Workspace to run benchmark notebooks.

1. Download the corresponding notebooks: **[PCADataGenerator.dbc](./PCADataGenerator.dbc)**  and **[PCAExample.dbc](./PCAExample.dbc)** .
2. Click the  **Workspace** icon or the  **Home** icon in the left sidebar.
3. Click **Down** caret in the Workspace or a user folder and select Import. 

![import-notebook](../imgs/import-notebook.png)

4. Browse to the notebook files downloaded to the local folder.
5. Click **Import**.


### Run benchmark notebooks

#### Run PCADataGenerator notebook to generate data.
 1. Create cluster with Databricks Runtime(Spark 3.1.1) .
 2. Open the notebook *benchmark_sklearn* and attach it to the corresponding cluster you created.
 3. Click **Run All**.
   
#### Run PCAExample to get performance
 1. Create cluster with Databricks Runtime(Spark 3.1.1) .
 2. Open the notebook *benchmark_sklearn* and attach it to the corresponding cluster you created.
 3. Click **Run All**.
