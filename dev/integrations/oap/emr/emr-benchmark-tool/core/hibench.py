from utils.util import *

HIBENCH_COMPONENT = "hibench"


def run_hibench(beaver_env, workload):
    cmd = "rm -rf " + os.path.join(beaver_env.get("HIBENCH_HOME"), "report") + "; cd  " + beaver_env.get("HIBENCH_HOME") + "&& bash bin/workloads/" + workload  + "/spark/run.sh"
    return os.system(cmd)
    # ssh_execute(master, cmd)

def gen_hibench_data(beaver_env, workload):
    cmd = "rm -rf " + os.path.join(beaver_env.get("HIBENCH_HOME"), "report") + "; bash " + os.path.join(os.path.join(os.path.join(beaver_env.get("HIBENCH_HOME"), "bin/workloads"), workload), "prepare/prepare.sh")
    os.system(cmd)
