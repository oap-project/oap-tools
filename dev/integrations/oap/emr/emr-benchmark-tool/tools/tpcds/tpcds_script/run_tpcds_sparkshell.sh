#!/usr/bin/bash -x

log_dir="{%tpcds.script.home%}/tpcds/logs"
rm -rf $log_dir
mkdir -p ${log_dir}

iteration=$1
if [ ! -n "iteration" ]; then
    echo "default iteration number is 1"
    iteration=1
fi

sed -i "s/iteration=[0-9]*/iteration=${iteration}/g" run_tpcds_sparkshell.scala

cat run_tpcds_sparkshell.scala | {%spark.home%}/bin/spark-shell --master yarn --deploy-mode client --jars {%sparksql.perf.home%}/target/scala-2.12/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar

echo "The summary results is saved as ${log_dir}/final_result.csv"
python {%tpcds.script.home%}/merge_csv_result.py $log_dir