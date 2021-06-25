import glob
import re
import time
import os
from utils.config_utils import *
from utils.colors import *
import shutil
from datetime import datetime
import smtplib
from email.mime.text import MIMEText
from email.header import Header
import socket
import subprocess

current_path = os.path.dirname(os.path.abspath(__file__))
project_path = os.path.dirname(current_path)
package_path = os.path.join(project_path, "package")
build_path = os.path.join(package_path, "build")
config_path = os.path.join(project_path, "conf")
local_repo_path = os.path.join(project_path, "repo")
tool_path = os.path.join(project_path, "tools")
oap_tools_source_code_path = os.path.join(package_path, "source_code/oap-tools")
oapperf_source_code_path = os.path.join(package_path, "source_code/oap-perf")


# Get all the defined properties from a property file
def get_properties(filename):
    properties = {}
    if not os.path.isfile(filename):
        return properties
    with open(filename) as f:
        for line in f:
            if line.startswith('#') or not line.split():
                continue
            key, value = line.partition("=")[::2]
            properties[key.strip()] = value.strip()
    return properties

def copy_spark_test_script_to_remote(script_folder, dst_path, dict):
    output_folder = os.path.join(package_path, "tmp/script/" + os.path.basename(script_folder))
    os.system("rm -rf " + output_folder)
    os.system("mkdir -p " + output_folder)
    os.system("cp -rf " + script_folder + "/* " + output_folder)
    output_folder_star = output_folder + "/*"
    final_config_files = glob.glob(output_folder_star)
    for file in final_config_files:
        if not os.path.isdir(file):
            replace_conf_value(file, dict)

    os.system("rm -rf " + dst_path)
    os.system("mkdir -p " + dst_path)

    output_folder = os.path.join(package_path, "tmp/script/" + os.path.basename(script_folder))
    os.system("cp -r " + output_folder + "/* " + dst_path)

def update_copy_spark_conf(custom_conf, beaver_env):
    spark_output_conf = update_conf("spark", custom_conf)
    # for conf_file in [file for file in os.listdir(spark_output_conf) if file.endswith(('.conf', '.xml'))]:
    #     output_conf_file = os.path.join(spark_output_conf, conf_file)
    #     # dict = get_spark_replace_dict(master, slaves, beaver_env, spark_version)
    #     replace_conf_value(output_conf_file, dict)
    copy_configurations(spark_output_conf, "spark", beaver_env.get("SPARK_HOME"))


def update_copy_hibench_conf(custom_conf, beaver_env):
    hibench_output_conf = update_conf("hibench", custom_conf)
    for conf_file in [file for file in os.listdir(hibench_output_conf) if file.endswith(('.conf', '.xml'))]:
        output_conf_file = os.path.join(hibench_output_conf, conf_file)
        dict = get_hibench_replace_dict(beaver_env)
        replace_conf_value(output_conf_file, dict)
    copy_configurations(hibench_output_conf, "hibench", beaver_env.get("HIBENCH_HOME"))

def get_hibench_replace_dict(beaver_env):
    print(colors.LIGHT_BLUE + "Update spark.conf and hadoop.conf" + colors.ENDC)
    hostname = socket.gethostname()
    hibench_hadoop_examples_jars = subprocess.check_output(
        "find " + beaver_env.get("HADOOP_HOME") + " -name hadoop-mapreduce-examples-*.jar", shell=True).decode('utf-8').strip('\r\n')
    if hibench_hadoop_examples_jars == "":
        hibench_hadoop_examples_jars = subprocess.check_output(
            "find " + os.path.join(os.path.dirname(beaver_env.get("HADOOP_HOME")), "hadoop-mapreduce") + " -name hadoop-mapreduce-examples-*.jar", shell=True).decode('utf-8').strip('\r\n')

    hibench_hadoop_examples_test_jars = subprocess.check_output(
        "find " + beaver_env.get("HADOOP_HOME") + " -name hadoop-mapreduce-client-jobclient-*tests.jar", shell=True).decode('utf-8').strip('\r\n')
    if hibench_hadoop_examples_test_jars == "":
        hibench_hadoop_examples_test_jars = subprocess.check_output(
        "find " + os.path.join(os.path.dirname(beaver_env.get("HADOOP_HOME")), "hadoop-mapreduce") + " -name hadoop-mapreduce-client-jobclient-*tests.jar", shell=True).decode('utf-8').strip('\r\n')
    hibench_version = hibench_get_build_version(beaver_env)
    dict = {'master_hostname':hostname,
            '{%hadoop.home%}':beaver_env.get("HADOOP_HOME"),
            '{%spark.home%}':beaver_env.get("SPARK_HOME"),
            '{%hibench.version%}':hibench_version,
            '{%hibench.hadoop.examples.jar%}':hibench_hadoop_examples_jars,
            '{%hibench.hadoop.examples.test.jar%}':hibench_hadoop_examples_test_jars}
    return dict

def hibench_get_build_version(beaver_env):
    hibench_ET = ET
    hibench_pom_tree = hibench_ET.parse(os.path.join(beaver_env.get("HIBENCH_HOME"), 'pom.xml'))
    hibench_pom_root = hibench_pom_tree.getroot()
    hibench_version = hibench_pom_root.find('{http://maven.apache.org/POM/4.0.0}version').text
    return hibench_version

def copy_configurations(config_path, component, home_path):
    print (colors.LIGHT_BLUE + "Distribute configuration files for " + component + ":" + colors.ENDC)
    print (colors.LIGHT_BLUE + "\tGenerate final configuration files of " + component + colors.ENDC)
    path = config_path + "/*"
    final_config_files = glob.glob(path)
    copy_final_configs(final_config_files, component, home_path)

def copy_final_configs(config_files, component, home_path):
    print (colors.LIGHT_BLUE + "\tCopy configuration files of " + component + " to all nodes" + colors.ENDC)
    if component == "spark":
        conf_link = os.path.join(home_path, "conf")
        conf_path = home_path + "/config/" + str(time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())) + "/"
        os.system("sudo mkdir -p " + conf_path)
        os.system("sudo cp -r " + conf_link + "/*" + " " + conf_path)
        for file in config_files:
            os.system("sudo cp -r " + file + " " + os.path.join(conf_link,  os.path.basename(file)))
    if component == "hibench":
        conf_link = os.path.join(home_path, "conf")
        conf_path = os.path.join(home_path, "config/") + str(time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())) + "/"
        os.system("mkdir -p " + conf_path)
        os.system("cp -r " + conf_link + "/*" + " " + conf_path)
        for file in config_files:
            if os.path.basename(file).strip("'\r\n'") in ["hadoop.conf", "spark.conf", "hibench.conf"]:
                os.system("cp -r " + file + " " + conf_path + os.path.basename(file))
            else:
                cmd = "find " + conf_path + " -name " + os.path.basename(file).strip("'\r\n'")
                # stdout = ssh_execute_withReturn(node, cmd)
                stdout = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE).stdout
                file_path = stdout.readlines()
#                for i in file_path:
#                    print(i.decode().strip("'\r\n'"))
                if len(file_path) == 1:
                    os.system("cp -r " + file + " " + file_path[0].decode().strip("'\r\n'"))
            os.system("rm -rf " + conf_link)
            os.system("ln -s " + conf_path + " " + conf_link)


def sendmail(subject, html_path, receivers, sender_name=""):
    sender = "root@" + socket.gethostname()
    with open(html_path, 'rb') as f:
        mail_body = f.read()
    message = MIMEText(mail_body, 'HTML', "utf-8")
    message['Subject'] = Header(subject, "utf-8")
    if sender_name:
        message['From'] = sender_name
    message['To'] = ",".join(receivers)
    try:
        smtp_obj = smtplib.SMTP('localhost')
        smtp_obj.sendmail(sender, receivers, message.as_string())
    except smtplib.SMTPException as e:
        print(e)

def get_conf_list(root_path, testing_conf_list, dataGen_conf_list):
    dir_or_files = os.listdir(root_path)
    for dir_file in dir_or_files:
        dir_file_path = os.path.join(root_path, dir_file)
        if os.path.isdir(dir_file_path):
            if os.path.exists(os.path.join(dir_file_path, ".base")):
                if verfiry_dataGen_conf(dir_file_path):
                    dataGen_conf_list.append(dir_file_path)
                else:
                    testing_conf_list.append(dir_file_path)
            else:
                get_conf_list(dir_file_path, testing_conf_list, dataGen_conf_list)

def verfiry_dataGen_conf(conf):
    beaver_env = get_merged_env(conf)
    if not beaver_env.get("GENERATE_DATA") is None and beaver_env.get("GENERATE_DATA").lower() == "true":
        return True
    else:
        return False

def verfiry_throughput_test_conf(conf):
    beaver_env = get_merged_env(conf)
    if not beaver_env.get("THROUGHPUT_TEST") is None and beaver_env.get("THROUGHPUT_TEST").lower() == "true":
        return True
    else:
        return False

def get_all_conf_list(root_path, testing_conf_list):
    dir_or_files = os.listdir(root_path)
    for dir_file in dir_or_files:
        dir_file_path = os.path.join(root_path, dir_file)
        if os.path.isdir(dir_file_path):
            if os.path.exists(os.path.join(dir_file_path, ".base")):
                testing_conf_list.append(dir_file_path)
            else:
                get_all_conf_list(dir_file_path, testing_conf_list)
