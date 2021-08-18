import os
import sys
import time
current_path = os.path.dirname(os.path.abspath(__file__))
project_path = os.path.dirname(current_path)
sys.path.append(project_path)
from utils.colors import *
from utils.util import *

def stop_spark_thrift_server(beaver_env):
    print (colors.LIGHT_BLUE + "Stop Spark thrift-server service..." + colors.ENDC)
    os.system("sudo " + beaver_env.get("SPARK_HOME") + "/sbin/stop-thriftserver.sh")

def start_spark_thrift_server(beaver_env):
    print (colors.LIGHT_BLUE + "Start Spark thrift-server service..." + colors.ENDC)
    os.system("sudo " + beaver_env.get("SPARK_HOME") + "/sbin/start-thriftserver.sh")

def stop_spark_service(beaver_env):
    stop_spark_thrift_server(beaver_env)

def start_spark_service(beaver_env):
    stop_spark_thrift_server(beaver_env)
    start_spark_thrift_server(beaver_env)

def start_plasma_service(beaver_env):
    if beaver_env.get("OAP_with_external").lower() == "true":
        # stop plasma service first
        print(colors.LIGHT_BLUE + "Stop plasma service" + colors.ENDC)
        stop_plasma_service(beaver_env)
        time.sleep(20)
        print (colors.LIGHT_BLUE + "Start plasma service" + colors.ENDC)
        update_plasma_conf(beaver_env)
        os.system("yarn app -launch plasma-store-service /tmp/plasmaLaunch.json")
        time.sleep(100)

def stop_plasma_service(beaver_env):
    if beaver_env.get("OAP_with_external").lower() == "true":
        update_plasma_conf(beaver_env)
        os.system("yarn app -stop plasma-store-service")
        os.system("yarn app -destroy plasma-store-service")


def update_plasma_conf(beaver_env):
    dict = gen_plasma_dict(beaver_env)
    os.system("rm -rf /tmp/plasmaLaunch.json")
    os.system("cp -rf " + os.path.join(tool_path, "plasma/plasmaLaunch.json") + " /tmp/ ")
    replace_conf_value("/tmp/plasmaLaunch.json", dict)

def gen_plasma_dict(beaver_env):
    dict = {};
    dict["{%oap.home%}"] = beaver_env.get("OAP_HOME")
    dict["{%plasma.cache.size%}"] = beaver_env.get("PLASMA_CACHE_SIZE")
    return dict