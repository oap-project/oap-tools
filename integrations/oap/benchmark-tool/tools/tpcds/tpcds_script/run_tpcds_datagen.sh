#!/usr/bin/bash -x
cat tpcds_datagen.scala | {%spark.home%}/bin/spark-shell --master yarn --deploy-mode client --jars {%sparksql.perf.home%}/target/scala-2.12/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar