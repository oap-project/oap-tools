#!/bin/bash

SPARK_HOME=/usr/lib/spark
SOFTWARE_HOME=/opt/software
LOG_HOME=${SOFTWARE_HOME}/log
sudo mkdir -p ${LOG_HOME}
sudo chown $(whoami):$(whoami) ${LOG_HOME}
TPCDS_LOG_HOME=${LOG_HOME}/tpcds
TPCH_LOG_HOME=${LOG_HOME}/tpch

echo original parameters=[$@]
args=`getopt -a -o grdpi:w:f:s:W:P: -l gen,rerun,iteration:,workload:,format:,scaleFactor:,doubleForDecimal,partitionTables,hibenchWorkload:,hibenchProfile:,Port: -- "$@"`
echo ARGS=[$args]
eval set -- "${args}"

echo formatted parameters=[$@]
runType=""
iteration=1
workload="tpcds"
format="parquet"
scaleFactor="1"
useDoubleForDecimal="false"
partitionTables="false"
hibenchWorkload="ml/kmeans"
hibenchProfile="tiny"
PORT=8020

while true
do
    case "$1" in
    -g|--gen)
        runType="gen"
        ;;
    -r|--rerun)
        runType="rerun"
        ;;
    -i|--iteration)
        iteration=$2
        shift
        ;;
    -w|--workload)
        workload=$2
        shift
        ;;
    -f|--format)
        format=$2
        shift
        ;;
    -s|--scaleFactor)
        scaleFactor=$2
        shift
        ;;
    -d|--doubleForDecimal)
        useDoubleForDecimal=true
        shift
        ;;
    -p|--partitionTables)
        partitionTables=true
        shift
        ;;
    -W|--hibenchWorkload)
        hibenchWorkload=$2
        shift
        ;;
    -P|--hibenchProfile)
        hibenchProfile=$2
        shift
        ;;
    --Port)
        PORT=$2
        shift
        ;;
    --)
	shift
	break
	;;
esac
shift
done

function usage() {
    echo "Support to run & generate data for HiBench, TPC-DS and TPC-H"
    echo "For HiBench, Usage: $0 -r|--rerun|-g|--gen -w|--workload hibench -W|--hibenchWorkload ml/kmeans|micro/terasort -P|--hibenchProfile tiny|small|large|huge|gigantic|bigdata --Port 8020|[customed hdfs port]"
    echo "For TPC-DS, Usage: $0 -r|--rerun|-g|--gen -w|--workload tpcds -i|--iteration 1 -f|--format parquet|orc -s|--scaleFactor 10 -d|--doubleForDecimal -p|--partitionTables --Port 8020|[customed hdfs port]"
    echo "For TPC-H, Usage: $0 -r|--rerun|-g|--gen -w|--workload tpch -i|--iteration 1 -f|--format parquet|orc -s|--scaleFactor 10 -d|--doubleForDecimal -p|--partitionTables --Port 8020|[customed hdfs port]"
    exit 1
}


function start_spark_thrift_server() {
    sudo ${SPARK_HOME}/sbin/stop-thriftserver.sh
    sudo ${SPARK_HOME}/sbin/start-thriftserver.sh
    sleep 60
}

function change_hdfs_permissions() {
    /usr/bin/hdfs dfs -chmod -R 777 /user
}

function create_tpcds_database_file() {
    mkdir -p ${TPCDS_LOG_HOME}
    echo "use tpcds_${format}_scale_${scaleFactor}_db;" > ${TPCDS_LOG_HOME}/dbname.txt
}

function create_tpch_database_file() {
    mkdir -p ${TPCH_LOG_HOME}
    echo "use tpch_${format}_scale_${scaleFactor}_db;" > ${TPCH_LOG_HOME}/dbname.txt
}

function create_tpcds_datagen_script() {
    mkdir -p ${TPCDS_LOG_HOME}
    echo "val tools_path = \"${SOFTWARE_HOME}/tpcds-kit/tools\"
    val data_path = \"hdfs://$(hostname):${PORT}/tpcds_${format}/${scaleFactor}\"
    val database_name = \"tpcds_${format}_scale_${scaleFactor}_db\"
    val scale = \"${scaleFactor}\"
    val p = scale.toInt / 2048.0
    val catalog_returns_p = (263 * p + 1).toInt
    val catalog_sales_p = (2285 * p * 0.5 * 0.5 + 1).toInt
    val store_returns_p = (429 * p + 1).toInt
    val store_sales_p = (3164 * p * 0.5 * 0.5 + 1).toInt
    val web_returns_p = (198 * p + 1).toInt
    val web_sales_p = (1207 * p * 0.5 * 0.5 + 1).toInt
    val format = \"${format}\"
    val codec = \"snappy\"
    val useDoubleForDecimal = ${useDoubleForDecimal}
    val partitionTables = ${partitionTables}
    val clusterByPartitionColumns = partitionTables
    import com.databricks.spark.sql.perf.tpcds.TPCDSTables
    spark.sqlContext.setConf(s\"spark.sql.\$format.compression.codec\", codec)
    val tables = new TPCDSTables(spark.sqlContext, tools_path, scale, useDoubleForDecimal)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"call_center\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"catalog_page\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"customer\", 6)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"customer_address\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"customer_demographics\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"date_dim\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"household_demographics\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"income_band\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"inventory\", 6)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"item\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"promotion\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"reason\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"ship_mode\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"store\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"time_dim\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"warehouse\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"web_page\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"web_site\", 1)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"catalog_sales\", catalog_sales_p)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"catalog_returns\", catalog_returns_p)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"store_sales\", store_sales_p)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"store_returns\", store_returns_p)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"web_sales\", web_sales_p)
    tables.genData(data_path, format, true, partitionTables, clusterByPartitionColumns, false, \"web_returns\", web_returns_p)
    tables.createExternalTables(data_path, format, database_name, overwrite = true, discoverPartitions = partitionTables)" > ${TPCDS_LOG_HOME}/tpcds_datagen.scala
}

function create_tpch_datagen_script() {
    mkdir -p ${TPCH_LOG_HOME}
    echo "import com.databricks.spark.sql.perf.tpch._
    val tools_path = \"${SOFTWARE_HOME}/tpch-dbgen\"
    val format = \"${format}\"
    val scaleFactor = \"${scaleFactor}\"
    val doubleForDecimal = ${useDoubleForDecimal}
    val partitionTables = ${partitionTables}
    val data_path=\"hdfs://$(hostname):${PORT}/tpch_${format}/${scaleFactor}\"
    val database_name = \"tpch_${format}_scale_${scaleFactor}_db\"
    val numPartitions = (scaleFactor.toInt / 512.0 * 100 + 1).toInt
    val clusterByPartitionColumns = partitionTables
    val tables = new TPCHTables(spark.sqlContext,
        dbgenDir = tools_path,
        scaleFactor = scaleFactor,
        useDoubleForDecimal = doubleForDecimal,
        useStringForDate = false)
    spark.sqlContext.setConf(\"spark.sql.files.maxRecordsPerFile\", \"20000000\")

    tables.genData(
        location = data_path,
        format = format,
        overwrite = true, // overwrite the data that is already there
        partitionTables, // do not create the partitioned fact tables
        clusterByPartitionColumns, // shuffle to get partitions coalesced into single files.
        filterOutNullPartitionValues = false, // true to filter out the partition with NULL key value
        tableFilter = \"\", // "" means generate all tables
        numPartitions = numPartitions) // how many dsdgen partitions to run - number of input tasks.
    sql(s\"drop database if exists \$database_name CASCADE\")
    sql(s\"create database \$database_name\")
    tables.createExternalTables(data_path, format, database_name, overwrite = true, discoverPartitions = false)" > ${TPCH_LOG_HOME}/tpch_datagen.scala
}

function create_tpch_arrow_tables_script() {
    mkdir -p ${TPCH_LOG_HOME}
    echo "val format = \"parquet\"
    val scaleFactor = \"${scaleFactor}\"
    val partitionTables = ${partitionTables}
    val data_path=\"hdfs://$(hostname):${PORT}/tpch_parquet/${scaleFactor}\"
    val database_name = \"tpch_arrow_scale_${scaleFactor}_db\"
    val tables = Seq(\"customer\", \"lineitem\", \"nation\", \"orders\", \"part\", \"partsupp\", \"region\", \"supplier\")

    if (spark.catalog.databaseExists(s\"\$database_name\")) {
        println(s\"\$database_name has exists!\")
    }else{
        spark.sql(s\"create database if not exists \$database_name\").show
        spark.sql(s\"use \$database_name\").show
        for (table <- tables) {
            if (spark.catalog.tableExists(s\"\$table\")){
                println(s\"\$table has exists!\")
            }else{
                spark.catalog.createTable(s\"\$table\", s\"\$data_path/\$table\", \"arrow\")
            }
        }
        if (partitionTables) {
            for (table <- tables) {
                try{
                    spark.sql(s\"ALTER TABLE \$table RECOVER PARTITIONS\").show
                }catch{
                    case e: Exception => println(e)
                }
            }
        }
    }" > ${TPCH_LOG_HOME}/native_create_table.scala
}

function create_tpcds_arrow_tables_script() {
    mkdir -p ${TPCDS_LOG_HOME}
    echo "val format = \"parquet\"
    val scaleFactor = \"${scaleFactor}\"
    val partitionTables = ${partitionTables}
    val data_path=\"hdfs://$(hostname):${PORT}/tpcds_parquet/${scaleFactor}\"
    val database_name = \"tpcds_arrow_scale_${scaleFactor}_db\"
    val tables = Seq(\"call_center\", \"catalog_page\", \"catalog_returns\", \"catalog_sales\", \"customer\", \"customer_address\", \"customer_demographics\", \"date_dim\", \"household_demographics\", \"income_band\", \"inventory\", \"item\", \"promotion\", \"reason\", \"ship_mode\", \"store\", \"store_returns\", \"store_sales\", \"time_dim\", \"warehouse\", \"web_page\", \"web_returns\", \"web_sales\", \"web_site\")
    if (spark.catalog.databaseExists(s\"\$database_name\")) {
        println(s\"\$database_name has exists!\")
    }else{
        spark.sql(s\"create database if not exists \$database_name\").show
        spark.sql(s\"use \$database_name\").show
        for (table <- tables) {
            if (spark.catalog.tableExists(s\"\$table\")){
                println(s\"\$table has exists!\")
            }else{
                spark.catalog.createTable(s\"\$table\", s\"\$data_path/\$table\", \"arrow\")
            }
        }
        if (partitionTables) {
            for (table <- tables) {
                try{
                    spark.sql(s\"ALTER TABLE \$table RECOVER PARTITIONS\").show
                }catch{
                    case e: Exception => println(e)
                }
            }
        }
    }" > ${TPCDS_LOG_HOME}/native_create_table.scala
}



function change_hibench_profile() {
    HiBench_HOME=${SOFTWARE_HOME}/HiBench
    sed "s/$(sed -n '/hibench.scale.profile/p' ${HiBench_HOME}/conf/hibench.conf)/hibench.scale.profile         ${hibenchProfile}/g" -i ${HiBench_HOME}/conf/hibench.conf
    hibench_hadoop_examples_jar=$(find /lib/hadoop-mapreduce/ -name  hadoop-mapreduce-examples-*.jar)
    hibench_hadoop_examples_test_jar=$(find /lib/hadoop-mapreduce/ -name hadoop-mapreduce-client-jobclient-3.2.1-*tests.jar)
    hibench_hadoop_examples_jar_line=$(sed -n '/hibench.hadoop.examples.jar/p' ${HiBench_HOME}/conf/hibench.conf)
    hibench_hadoop_examples_test_jar_line=$(sed -n '/hibench.hadoop.examples.test.jar/p' ${HiBench_HOME}/conf/hibench.conf)
    if [ -n "$(sed -n '/hibench.hadoop.examples.jar/=' ${HiBench_HOME}/conf/hibench.conf)" ]; then
        sed 's/${hibench_hadoop_examples_jar_line}/hibench.hadoop.examples.jar              ${hibench_hadoop_examples_jar}/g' -i ${HiBench_HOME}/conf/hibench.conf
    else
        sed -i '$a hibench.hadoop.examples.jar           '${hibench_hadoop_examples_jar}'' ${HiBench_HOME}/conf/hibench.conf
    fi
    if [ -n "$(sed -n '/hibench.hadoop.examples.test.jar/=' ${HiBench_HOME}/conf/hibench.conf)" ]; then
        sed 's/${hibench_hadoop_examples_test_jar_line}/hibench.hadoop.examples.test.jar            ${hibench_hadoop_examples_test_jar}/g' -i ${HiBench_HOME}/conf/hibench.conf
    else
        sed -i '$a hibench.hadoop.examples.test.jar         '${hibench_hadoop_examples_test_jar}'' ${HiBench_HOME}/conf/hibench.conf
    fi
}


if [ "${runType}" = "rerun" ]; then
    if [ "${workload}" = "tpcds" ]; then
        rm -rf ${TPCDS_LOG_HOME}/*
        create_tpcds_database_file
        change_hdfs_permissions
        queriesdir=$SOFTWARE_HOME/spark-sql-perf/src/main/resources/tpcds_2_4
        if [ "${format}" = "arrow" ]; then
            create_tpcds_arrow_tables_script
            cat ${TPCDS_LOG_HOME}/native_create_table.scala | ${SPARK_HOME}/bin/spark-shell --master yarn --deploy-mode client
        fi
        start_spark_thrift_server
        for round in $(seq $iteration);do
            echo "Runing ${workload} ${round} round"!
            mkdir -p ${TPCDS_LOG_HOME}/${round}
            for t in $(seq 99);do
                if [ $t == 14 ] || [ $t == 23 ] || [ $t == 24 ] || [ $t == 39 ]; then
                    if [ -e "${queriesdir}/q${t}a.sql" ]; then
                        start=$(date +%s)
                        $SPARK_HOME/bin/beeline -u jdbc:hive2://$(hostname):10001 -i ${TPCDS_LOG_HOME}/dbname.txt -f ${queriesdir}/q${t}a.sql > ${TPCDS_LOG_HOME}/${round}/q${t}a.log 2>&1
                        end=$(date +%s)
                        time=$(( $end - $start ))
                        Error_message=$(grep -r "Error:" ${TPCDS_LOG_HOME}/${round}/q${t}a.log | wc -l )
                        if [ ${Error_message} -gt 0 ] ; then
                            RES=Fail;
                        else
                            RES=Success;
                        fi
                        echo "q${t}a $time $RES" >> ${TPCDS_LOG_HOME}/${round}/result.log
                        echo "q${t}a,$time,$RES" >> ${TPCDS_LOG_HOME}/${round}/result.csv
                    fi
                    if [ -e "${queriesdir}/q${t}b.sql" ]; then
                        start=$(date +%s)
                        $SPARK_HOME/bin/beeline -u jdbc:hive2://$(hostname):10001 -i ${TPCDS_LOG_HOME}/dbname.txt -f ${queriesdir}/q${t}b.sql > ${TPCDS_LOG_HOME}/${round}/q${t}b.log 2>&1
                        end=$(date +%s)
                        time=$(( $end - $start ))
                        Error_message=$(grep -r "Error:" ${TPCDS_LOG_HOME}/${round}/q${t}b.log | wc -l )
                        if [ ${Error_message} -gt 0 ] ; then
                            RES=Fail;
                        else
                            RES=Success;
                        fi
                        echo "q${t}b $time $RES" >> ${TPCDS_LOG_HOME}/${round}/result.log
                        echo "q${t}b,$time,$RES" >> ${TPCDS_LOG_HOME}/${round}/result.csv
                    fi
                else
                    if [ -e "${queriesdir}/q${t}.sql" ]; then
                        start=$(date +%s)
                        $SPARK_HOME/bin/beeline -u jdbc:hive2://$(hostname):10001 -i ${TPCDS_LOG_HOME}/dbname.txt -f ${queriesdir}/q${t}.sql > ${TPCDS_LOG_HOME}/${round}/q${t}.log 2>&1
                        end=$(date +%s)
                        time=$(( $end - $start ))
                        Error_message=$(grep -r "Error:" ${TPCDS_LOG_HOME}/${round}/q${t}.log | wc -l )
                        if [ ${Error_message} -gt 0 ] ; then
                            RES=Fail;
                        else
                            RES=Success;
                        fi
                        echo "q${t} $time $RES" >> ${TPCDS_LOG_HOME}/${round}/result.log
                        echo "q${t},$time,$RES" >> ${TPCDS_LOG_HOME}/${round}/result.csv
                    fi
                fi
            done
            echo "The result directory is: ${TPCDS_LOG_HOME}/${round}"
        done
    elif [ "${workload}" = "tpch" ]; then
        rm -rf ${TPCH_LOG_HOME}/*
        create_tpch_database_file
        change_hdfs_permissions
        queriesdir=$SOFTWARE_HOME/spark-sql-perf/src/main/resources/tpch/queries
        if [ "${format}" = "arrow" ]; then
            create_tpch_arrow_tables_script
            cat ${TPCH_LOG_HOME}/native_create_table.scala | ${SPARK_HOME}/bin/spark-shell --master yarn --deploy-mode client
        fi
        start_spark_thrift_server
        for round in $(seq $iteration);do
            echo "Runing ${workload} ${round} round"!
            mkdir -p ${TPCH_LOG_HOME}/${round}
            for t in $(seq 22);do
                if [ -e "${queriesdir}/${t}.sql" ]; then
                    start=$(date +%s)
                    $SPARK_HOME/bin/beeline -u jdbc:hive2://$(hostname):10001 -i ${TPCH_LOG_HOME}/dbname.txt -f ${queriesdir}/${t}.sql > ${TPCH_LOG_HOME}/${round}/q${t}.log 2>&1
                    end=$(date +%s)
                    time=$(( $end - $start ))
                    Error_message=$(grep -r "Error:" ${TPCH_LOG_HOME}/${round}/q${t}.log | wc -l )
                    if [ ${Error_message} -gt 0 ] ; then
                        RES=Fail;
                    else
                        RES=Success;
                    fi
                    echo "q${t} $time $RES" >> ${TPCH_LOG_HOME}/${round}/result.log
                    echo "q${t},$time,$RES" >> ${TPCH_LOG_HOME}/${round}/result.csv
                fi
            done
            echo "The result directory is: ${TPCDS_LOG_HOME}/${round}"
        done
    elif [ "${workload}" = "hibench" ]; then
        change_hdfs_permissions
        cd ${SOFTWARE_HOME}/HiBench && sh bin/workloads/${hibenchWorkload}/spark/run.sh
    fi

elif [ "${runType}" = "gen" ]; then
    if [ "${workload}" = "tpcds" ]; then
        create_tpcds_datagen_script
        cat ${TPCDS_LOG_HOME}/tpcds_datagen.scala | ${SPARK_HOME}/bin/spark-shell --master yarn --deploy-mode client --jars ${SOFTWARE_HOME}/spark-sql-perf/target/scala-2.12/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar
    elif [ "${workload}" = "tpch" ]; then
        create_tpch_datagen_script
        cat ${TPCH_LOG_HOME}/tpch_datagen.scala | ${SPARK_HOME}/bin/spark-shell --master yarn --deploy-mode client --jars ${SOFTWARE_HOME}/spark-sql-perf/target/scala-2.12/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar
    elif [ "${workload}" = "hibench" ]; then
        change_hibench_profile
        cd ${SOFTWARE_HOME}/HiBench && sh bin/workloads/${hibenchWorkload}/prepare/prepare.sh
    fi
else
    usage
fi
