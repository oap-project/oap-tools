val data_format = "{%data.format%}"
val scale = {%scale%}
val partitionTables = {%partitionTables%}
val data_path=s"{%storage%}://{%s3.bucket%}/datagen/tpcds_${data_format}{%partitioned%}/${scale}"
val databaseName = s"tpcds_arrow{%partitioned%}_scale_${scale}_db"
val tables = Seq("call_center", "catalog_page", "catalog_returns", "catalog_sales", "customer", "customer_address", "customer_demographics", "date_dim", "household_demographics", "income_band", "inventory", "item", "promotion", "reason", "ship_mode", "store", "store_returns", "store_sales", "time_dim", "warehouse", "web_page", "web_returns", "web_sales", "web_site")

if (spark.catalog.databaseExists(s"$databaseName")) {
    println(s"$databaseName has exists!")
}else{
    spark.sql(s"create database if not exists $databaseName").show
    spark.sql(s"use $databaseName").show
    for (table <- tables) {
        if (spark.catalog.tableExists(s"$table")){
            println(s"$table has exists!")
        }else{
            spark.catalog.createTable(s"$table", s"$data_path/$table", "arrow")
        }
    }
    if (partitionTables) {
        for (table <- tables) {
            try{
                spark.sql(s"ALTER TABLE $table RECOVER PARTITIONS").show
            }catch{
                    case e: Exception => println(e)
            }
        }
    }
}

//spark.catalog.createTable("call_center", "hdfs:////user/root/tpcds_500/call_center", "arrow")
//spark.catalog.createTable("catalog_page", "hdfs:////user/root/tpcds_500/catalog_page", "arrow")
//spark.catalog.createTable("catalog_returns", "hdfs:////user/root/tpcds_500/catalog_returns", "arrow")
//spark.catalog.createTable("catalog_sales", "hdfs:////user/root/tpcds_500/catalog_sales", "arrow")
//spark.catalog.createTable("customer", "hdfs:////user/root/tpcds_500/customer", "arrow")
//spark.catalog.createTable("customer_address", "hdfs:////user/root/tpcds_500/customer_address", "arrow")
//spark.catalog.createTable("customer_demographics", "hdfs:////user/root/tpcds_500/customer_demographics", "arrow")
//spark.catalog.createTable("date_dim", "hdfs:////user/root/tpcds_500/date_dim", "arrow")
//spark.catalog.createTable("household_demographics", "hdfs:////user/root/tpcds_500/household_demographics", "arrow")
//spark.catalog.createTable("income_band", "hdfs:////user/root/tpcds_500/income_band", "arrow")
//spark.catalog.createTable("inventory", "hdfs:////user/root/tpcds_500/inventory", "arrow")
//spark.catalog.createTable("item", "hdfs:////user/root/tpcds_500/item", "arrow")
//spark.catalog.createTable("promotion", "hdfs:////user/root/tpcds_500/promotion", "arrow")
//spark.catalog.createTable("reason", "hdfs:////user/root/tpcds_500/reason", "arrow")
//spark.catalog.createTable("ship_mode", "hdfs:////user/root/tpcds_500/ship_mode", "arrow")
//spark.catalog.createTable("store", "hdfs:////user/root/tpcds_500/store", "arrow")
//spark.catalog.createTable("store_returns", "hdfs:////user/root/tpcds_500/store_returns", "arrow")
//spark.catalog.createTable("store_sales", "hdfs:////user/root/tpcds_500/store_sales", "arrow")
//spark.catalog.createTable("time_dim", "hdfs:////user/root/tpcds_500/time_dim", "arrow")
//spark.catalog.createTable("warehouse", "hdfs:////user/root/tpcds_500/warehouse", "arrow")
//spark.catalog.createTable("web_page", "hdfs:////user/root/tpcds_500/web_page", "arrow")
//spark.catalog.createTable("web_returns", "hdfs:////user/root/tpcds_500/web_returns", "arrow")
//spark.catalog.createTable("web_sales", "hdfs:////user/root/tpcds_500/web_sales", "arrow")
//spark.catalog.createTable("web_site", "hdfs:////user/root/tpcds_500/web_site", "arrow")
