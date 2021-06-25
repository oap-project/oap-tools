import os
import sys
current_path = os.path.dirname(os.path.abspath(__file__))
project_path = os.path.dirname(current_path)
sys.path.append(project_path)
from core.spark_sql_perf import *

current_path = os.path.dirname(os.path.abspath(__file__))

def gen_data(custom_conf):
    beaver_env = get_merged_env(custom_conf)
    gen_tpc_data(beaver_env, "tpch")


def run_query(custom_conf, iteration):
    beaver_env = get_merged_env(custom_conf)
    return run_tpc_query(beaver_env, iteration, "tpch")

def update(custom_conf):
    beaver_env = get_merged_env(custom_conf)
    update_copy_spark_conf(custom_conf, beaver_env)
    deploy_spark_sql_perf(custom_conf)

def update_and_run(custom_conf, iteration):
    update(custom_conf)
    run_query(custom_conf, iteration)


def usage():
    print("Usage: benchmark/TPCHonSparkSQL.sh [action] [conf_dir] [plugins] [iteration]/n")
    print("   Action option includes: update, gen_data, run, update_and_run /n")
    print("           update        : [conf_dir], just replace configurations and restart cluster/n")
    print("           gen_data      : [conf_dir] generate TPC-DS data/n")
    print("           run           : [conf_dir] [iteration], the default value of iteration is '1' if iteration is empty /n")
    print("           update_and_run: [conf_dir] [iteration] just replace configurations, restart the cluster and trigger a run /n")
    exit(1)


if __name__ == '__main__':
    args = sys.argv
    if len(args) < 3:
        usage()
    action = args[1]
    conf_path = args[2]

    if action == "update":
        update(conf_path)
    elif action == "gen_data":
        gen_data(conf_path)
    elif action == "run":
        if len(args) == 4:
            iteration = args[3]
        else:
            iteration = 1
        run_query(conf_path, iteration)
    elif action == "update_and_run":
        if len(args) == 4:
            iteration = args[3]
        else:
            iteration = 1
        update_and_run(conf_path, iteration)
    else:
        usage()
