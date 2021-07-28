#!/bin/bash

SPARK_PHIVE_HOME="{%spark.home%}"
tpch_script_home="{%tpch.script.home%}"
queries_dir="${tpch_script_home}/tpch/tpch-queries"
source ${tpch_script_home}/config
LOG_DIR="${tpch_script_home}/tpch/logs"

start=$(($(date +%s%N)/1000000))
log info "Run stream $1 started."
start_time=$(date +%s)
${SPARK_PHIVE_HOME}/bin/beeline --showStartEndTime=true -u jdbc:hive2://{%hostname%}:10001 -i $2 -f ${queries_dir}/queries/query_$1.sql > ${LOG_DIR}/stream_$1.out 2> ${LOG_DIR}/stream_$1.err
end_time=$(date +%s)
time=$(( $end_time - $start_time ))
Error_message=$(grep -r "Error:" ${LOG_DIR}/stream_$1.err | wc -l )
if [ ${Error_message} -gt 0 ] ; then
    RES=Fail;
    echo "stream_$1,-$time,$RES" >> ${LOG_DIR}/final_result.csv
else
    RES=Success;
    echo "stream_$1,$time,$RES" >> ${LOG_DIR}/final_result.csv
fi

end=$(($(date +%s%N)/1000000))
duration=$(( (end - start) / 1000))
sec=`bc <<< "scale=3; ($end - $start)/1000"`
elapse_time=`printf "%d:%02d:%02d, %s seconds" $(($duration / 3600)) $((($duration / 60) % 60)) $(($duration % 60)) $sec`
log info "Run stream $1 finished. Time token: $elapse_time"
