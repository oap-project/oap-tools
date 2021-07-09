import com.databricks.spark.sql.perf.tpch._

val tools_path = "{%tpch.home%}"
val data_path="{%storage%}://{%s3.bucket%}/datagen/tpch_{%data.format%}{%partitioned%}/{%scale%}"
val scaleFactor = "{%scale%}"
val numPartitions ={%partition%}
val databaseName = "tpch_{%data.format%}{%partitioned%}_scale_{%scale%}_db"
val format = "{%data.format%}"

val doubleForDecimal = false

val partitionTables = {%partitionTables%}
val clusterByPartitionColumns = partitionTables

val tables = new TPCHTables(spark.sqlContext,
    dbgenDir = tools_path,
    scaleFactor = scaleFactor,
    useDoubleForDecimal = doubleForDecimal,
    useStringForDate = false)

spark.sqlContext.setConf("spark.sql.files.maxRecordsPerFile", "20000000")

tables.genData(
    location = data_path,
    format = format,
    overwrite = true, // overwrite the data that is already there
    partitionTables, // do not create the partitioned fact tables
    clusterByPartitionColumns, // shuffle to get partitions coalesced into single files.
    filterOutNullPartitionValues = false, // true to filter out the partition with NULL key value
    tableFilter = "", // "" means generate all tables
    numPartitions = numPartitions) // how many dsdgen partitions to run - number of input tasks.

// Create the specified database
sql(s"drop database if exists $databaseName CASCADE")
sql(s"create database $databaseName")
// Create metastore tables in a specified database for your data.
// Once tables are created, the current database will be switched to the specified database.
tables.createExternalTables(data_path, format, databaseName, overwrite = true, discoverPartitions = false)
