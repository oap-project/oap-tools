import scala.io.Source
import java.io.PrintWriter
import scala.reflect.io.Directory
import java.io.File
import java.util.Date

val iteration=6
val use_arrow = {%arrow_enable%}
var databaseName = s"tpcds_{%data.format%}{%partitioned%}_scale_${scale}_db"
val log_location="{%sparksql.perf.home%}/tpcds_script/tpcds"
if (use_arrow){
    val data_format = "{%data.format%}"
    val scale = {%scale%}
    val partitionTables = {%partitionTables%}
    val data_path=s"{%storage%}://{%s3.bucket%}/datagen/tpcds_${data_format}{%partitioned%}/${scale}"
    databaseName = s"tpcds_arrow{%partitioned%}_scale_${scale}_db"
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
}

sql(s"use $databaseName")

for (round <- 1 to iteration){
    val directory = new Directory(new File(s"$log_location/logs/$round"))   //create log directory for each round
    directory.createDirectory(true, false)
    val each_round_result = new PrintWriter(s"$log_location/logs/$round/result.csv")      // each round result
    val queries = (1 to 99).map { q =>
        if new File(s"${log_location}/tpcds-queries/q${q}.sql").exists() {
            val start_time = new Date().getTime                                 // the starting time of query
            val query_log = new PrintWriter(s"$log_location/logs/$round/${q}.log") //query log
            val queryContent: String = Source.fromFile(s"${log_location}/tpcds-queries/q${q}.sql").mkString  //query string
            println(queryContent)
            val df = spark.sql(s"$queryContent")
            query_log.println(df.columns.mkString(","))   //get all columns name and save into file
            try {
                val df_row = df.collect                 //get all Row data
                val end_time = new Date().getTime       //the ending time of query
                for (i <- 0 to (df_row.length - 1)){
                    query_log.println(df_row(i).mkString(",")) //get each column data and save into file
                }
                val elapse_time = (end_time - start_time) / 1000   //the elapsed time of query
                each_round_result.println(s"q${q},${elapse_time},Success")
            } catch {
                case ex: Exception => {
                    query_log.println(ex.getStackTraceString)
                    out.println(s"q${q},-1,Fail")
                }
            } finally {
                query_log.close
            }
        }

        if new File(s"${log_location}/tpcds-queries/q${q}a.sql").exists() {
            val start_time = new Date().getTime                                 // the starting time of query
            val query_log = new PrintWriter(s"$log_location/logs/$round/${q}a.log") //query log
            val queryContent: String = Source.fromFile(s"${log_location}/tpcds-queries/q${q}a.sql").mkString  //query string
            println(queryContent)
            val df = spark.sql(s"$queryContent")
            query_log.println(df.columns.mkString(","))   //get all columns name and save into file
            try {
                val df_row = df.collect                 //get all Row data
                val end_time = new Date().getTime       //the ending time of query
                for (i <- 0 to (df_row.length - 1)){
                    query_log.println(df_row(i).mkString(",")) //get each column data and save into file
                }
                val elapse_time = (end_time - start_time) / 1000   //the elapsed time of query
                each_round_result.println(s"q${q}a,${elapse_time},Success")
            } catch {
                case ex: Exception => {
                    query_log.println(ex.getStackTraceString)
                    out.println(s"q${q}a,-1,Fail")
                }
            } finally {
                query_log.close
            }
        }

        if new File(s"${log_location}/tpcds-queries/q${q}b.sql").exists() {
            val start_time = new Date().getTime                                 // the starting time of query
            val query_log = new PrintWriter(s"$log_location/logs/$round/${q}b.log") //query log
            val queryContent: String = Source.fromFile(s"${log_location}/tpcds-queries/q${q}b.sql").mkString  //query string
            println(queryContent)
            val df = spark.sql(s"$queryContent")
            query_log.println(df.columns.mkString(","))   //get all columns name and save into file
            try {
                val df_row = df.collect                 //get all Row data
                val end_time = new Date().getTime       //the ending time of query
                for (i <- 0 to (df_row.length - 1)){
                    query_log.println(df_row(i).mkString(",")) //get each column data and save into file
                }
                val elapse_time = (end_time - start_time) / 1000   //the elapsed time of query
                each_round_result.println(s"q${q}b,${elapse_time},Success")
            } catch {
                case ex: Exception => {
                    query_log.println(ex.getStackTraceString)
                    out.println(s"q${q}b,-1,Fail")
                }
            } finally {
                query_log.close
            }
        }
    }
    each_round_result.close
}





