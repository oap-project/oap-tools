#!/bin/bash
iteration=$1
arrow_enable=$2

SPARK_PHIVE_HOME="{%spark.home%}"
tpcds_script_home="{%tpcds.script.home%}"
queries_dir="${tpcds_script_home}/tpcds/tpcds-queries"
source ${tpcds_script_home}/config
unset SPARK_HOME
sudo $SPARK_PHIVE_HOME/sbin/stop-thriftserver.sh

if [ -n "${arrow_enable}" ] && [ "${arrow_enable}" = "arrow" ] ;then
    dbname_file="${tpcds_script_home}/dbname_arrow.txt"
    echo "Checking whether the database for arrow data has exists or not!"
    cat ${tpcds_script_home}/native_create_table.scala | ${SPARK_PHIVE_HOME}/bin/spark-shell --master yarn --deploy-mode client
else
    dbname_file="${tpcds_script_home}/dbname.txt"
fi

STATISTIC=$(date --date="+1 day" +"%Y-%m-%d")

log_dir="${tpcds_script_home}/tpcds/logs"
rm -rf $log_dir
mkdir -p ${log_dir}
LOG=${log_dir}/throughput_test.log
sudo $SPARK_PHIVE_HOME/sbin/start-thriftserver.sh
sleep 60

log info "Throughtput test started." | tee -a $LOG 2>&1
start=$(date +%s)

if [ $1 -ne 2 ]; then
  bash ${tpcds_script_home}/run_stream.sh 1 ${dbname_file} | tee -a $LOG 2>&1 &
  bash ${tpcds_script_home}/run_stream.sh 2 ${dbname_file} | tee -a $LOG 2>&1 &
  bash ${tpcds_script_home}/run_stream.sh 3 ${dbname_file} | tee -a $LOG 2>&1 &
  bash ${tpcds_script_home}/run_stream.sh 4 ${dbname_file} | tee -a $LOG 2>&1 &
else
  bash ${tpcds_script_home}/run_stream.sh 5 ${dbname_file} | tee -a $LOG 2>&1 &
  bash ${tpcds_script_home}/run_stream.sh 6 ${dbname_file} | tee -a $LOG 2>&1 &
  bash ${tpcds_script_home}/run_stream.sh 7 ${dbname_file} | tee -a $LOG 2>&1 &
  bash ${tpcds_script_home}/run_stream.sh 8 ${dbname_file} | tee -a $LOG 2>&1 &
fi

wait
end=$(date +%s)
time=$(( $end - $start ))
Error_message=$(grep -r "Error:" ${log_dir}/stream_*.err | wc -l )
if [ ${Error_message} -gt 0 ] ; then
    echo "total,-$time,Fail" >> ${log_dir}/final_result.csv
else
    echo "total,$time,Success" >> ${log_dir}/final_result.csv
fi

log info "Throughtput test finished." | tee -a $LOG 2>&1
sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'
echo "cache dropped"

sudo $SPARK_PHIVE_HOME/sbin/stop-thriftserver.sh
