val data_format = "{%data.format%}"
val scale = {%scale%}
val partitionTables = {%partitionTables%}
val data_path=s"{%storage%}://{%s3.bucket%}/datagen/tpch_${data_format}{%partitioned%}/${scale}"
val databaseName = s"tpch_arrow{%partitioned%}_scale_${scale}_db"
val tables = Seq("customer", "lineitem", "nation", "orders", "part", "partsupp", "region", "supplier")

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

//spark.sql(s"create database if not exits $databaseName").show
//spark.sql(s"use $databaseName").show
//spark.catalog.createTable("customer", s"$data_path/customer", "arrow")
//spark.catalog.createTable("lineitem", s"$data_path/lineitem", "arrow")
//spark.catalog.createTable("nation", s"$data_path/nation", "arrow")
//spark.catalog.createTable("orders", s"$data_path/orders", "arrow")
//spark.catalog.createTable("part", s"$data_path/part", "arrow")
//spark.catalog.createTable("partsupp", s"$data_path/partsupp", "arrow")
//spark.catalog.createTable("region", s"$data_path/region", "arrow")
//spark.catalog.createTable("supplier", s"$data_path/supplier", "arrow")