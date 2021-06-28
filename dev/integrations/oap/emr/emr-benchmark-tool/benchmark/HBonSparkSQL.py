#!/usr/bin/python
import os
import sys
current_path = os.path.dirname(os.path.abspath(__file__))
project_path = os.path.dirname(current_path)
sys.path.append(project_path)
from core.hibench import *


def gen_data(custom_conf, workload):
    beaver_env = get_merged_env(custom_conf)
    gen_hibench_data(beaver_env, workload)

def run_workload(custom_conf, workload):
    beaver_env = get_merged_env(custom_conf)
    return run_hibench(beaver_env, workload)

def update(custom_conf):
    beaver_env = get_merged_env(custom_conf)
    update_copy_hibench_conf(custom_conf, beaver_env)


def update_and_run(custom_conf, workload):
    update(custom_conf)
    run_workload(custom_conf, workload)


def usage():
    print("Usage: benchmark/HBonSparkSQL.sh [action] [conf_dir] [plugins] [workload]/n")
    print("   Action option includes: update, gen_data, run, update_and_run /n")
    print("           update        : [conf_dir], just replace configurations and restart cluster/n")
    print("           gen_data      : [conf_dir] [workload], generate [workload] data/n")
    print("           run           : [conf_dir] [workload], workload] cannot be empty /n")
    print("           update_and_run: [conf_dir] [workload] just replace configurations, restart the cluster and trigger a run /n")
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
        workload = ""
        if len(args) == 4:
            workload = args[3]
        else:
            usage()
            exit(1)
        gen_data(conf_path, workload)
    elif action == "run":
        workload = ""
        if len(args) == 4:
            workload = args[3]
        else:
            usage()
            exit(1)
        run_workload(conf_path, workload)
    elif action == "update_and_run":
        workload = ""
        if len(args) == 4:
            workload = args[3]
        else:
            usage()
            exit(1)
        update_and_run(conf_path, workload)
    else:
        usage()
