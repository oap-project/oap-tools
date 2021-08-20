val scale = "1"
val format = "parquet"
val storage_path = "s3a://aws-emr-resources-348941870272-us-east-2/eks/"
// how many times to run the whole set of queries
val iterations = 1

val database_name = s"tpcds_${format}_${scale}_db"
// Seq() == all queries
// Seq("q26-v2.4", "q27-v2.4") // run subset of queries
val query_filter = Seq("q26-v2.4", "q27-v2.4")
var resultLocation = s"${storage_path}/results/tpcds_${format}_${scale}/"
// run queries in a random order
val randomizeQueries = false
val timeout = 60 // timeout in hours
// COMMAND ----------
sql(s"use $database_name")
import com.databricks.spark.sql.perf.tpcds.TPCDS
val tpcds = new TPCDS (sqlContext = spark.sqlContext)
def queries = {
  val filtered_queries = query_filter match {
    case Seq() => tpcds.tpcds2_4Queries
    case _ => tpcds.tpcds2_4Queries.filter(q => query_filter.contains(q.name))
  }
  if (randomizeQueries) scala.util.Random.shuffle(filtered_queries) else filtered_queries
}
val experiment = tpcds.runExperiment(
  queries, 
  iterations = iterations,
  resultLocation = resultLocation,
  tags = Map("runtype" -> "benchmark", "database" -> database_name, "scale_factor" -> scale))

println(experiment.toString)
experiment.waitForFinish(timeout*60*60)



