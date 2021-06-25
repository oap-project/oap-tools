#!/bin/bash
iteration=$1
arrow_enable=$2

SPARK_PHIVE_HOME="{%spark.home%}"
tpch_script_home="{%tpch.script.home%}"
queriesdir="${tpch_script_home}/tpch/tpch-queries"

unset SPARK_HOME
sudo $SPARK_PHIVE_HOME/sbin/stop-thriftserver.sh

if  [ -n "${arrow_enable}" ] && [ "${arrow_enable}" = "arrow" ] ;then
    echo "Checking databases for arrow format"
    dbname_file="${tpch_script_home}/dbname_arrow.txt"
    cat ${tpch_script_home}/native_create_table.scala | ${SPARK_PHIVE_HOME}/bin/spark-shell --master yarn --deploy-mode client
else
    dbname_file="${tpch_script_home}/dbname.txt"
fi
STATISTIC=$(date --date="+1 day" +"%Y-%m-%d")

log_dir="${tpch_script_home}/tpch/logs"
rm -rf $log_dir
mkdir -p ${log_dir}
sudo $SPARK_PHIVE_HOME/sbin/start-thriftserver.sh
queries="{%queries%}"
sleep 60

for round in $(seq $iteration);do
    echo "Runing $round round"!
    log_current_dir=${log_dir}/$round
    mkdir ${log_current_dir}
    for t in ${queries[@]};do
        if [ $t == 64 ]
            then
            continue
        fi
        start=$(date +%s)
        if [ -e "${queriesdir}/${t}.sql" ]; then
            $SPARK_PHIVE_HOME/bin/beeline -u jdbc:hive2://{%hostname%}:10001 -i ${dbname_file} -f ${queriesdir}/${t}.sql > ${log_current_dir}/q${t}.log 2>&1
            wait $!

            Error_message=$(grep -r "Error:" ${log_current_dir}/q${t}.log | wc -l )
            if [ ${Error_message} -gt 0 ] ; then
                RES=Fail;
            else
                RES=Success;
            fi
            end=$(date +%s)
            time=$(( $end - $start ))
            echo "q${t} $time $RES" >> ${log_current_dir}/result.log
            echo "q${t},$time,$RES" >> ${log_current_dir}/result.csv
        fi
    done
    echo "The result directory is: ${log_current_dir}"
done
echo "The summary results is saved as ${log_dir}/final_result.csv"
python ${tpch_script_home}/merge_csv_result.py $log_dir

sudo $SPARK_PHIVE_HOME/sbin/stop-thriftserver.sh