#!/bin/bash
BENCHMARK_TOOL_HOME=$(cd $(dirname ${BASH_SOURCE[0]})/..;pwd)

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 update|gen_data|run|update_and_run conf_dir [iterations]" >&2
  exit 1
fi
if ! [ -d "$2" ]; then
  echo "$2 is not a directory" >&2
  exit 1
fi

action=$1
conf_dir=$2
shift 2

echo "tpc-ds $action ..."
python ${BENCHMARK_TOOL_HOME}/benchmark/TPCDSonSparkSQL.py $action $conf_dir "$@"
