// Read parquet with Native-SQL-Engine
val usersDF = spark.read.format("arrow").load("/opt/home/spark-3.0.0/examples/src/main/resources/users.parquet")
usersDF.select("name", "favorite_color").show


