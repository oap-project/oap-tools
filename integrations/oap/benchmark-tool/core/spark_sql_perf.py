#!/usr/bin/python

from utils.util import *

SPARK_SQL_PERF_COMPONENT = "spark-sql-perf"
TPCDS_COMPONENT = "TPC-DS"
TPCH_COMPONENT = "TPC-H"

def deploy_spark_sql_perf(custom_conf, test_mode=[]):
    print("Deploy spark_sql_perf")
    clean_spark_sql_perf()
    beaver_env = get_merged_env(custom_conf)
    copy_tpcds_test_script(custom_conf, beaver_env, test_mode)
    copy_tpch_test_script(custom_conf, beaver_env, test_mode)

def undeploy_spark_sql_perf():
    print("Undeploy spark_sql_perf")
    clean_spark_sql_perf()

def run_tpc_query(beaver_env, iteration, workload):
    script_folders = os.path.join(beaver_env.get("SPARK_SQL_PERF_HOME"), workload + "_script")
    arrow_format = ""
    if beaver_env.get("NATIVE_SQL_ENGINE").lower() == "true":
        arrow_format = "arrow"
    print (colors.LIGHT_BLUE + "\tStart to run test..." + colors.ENDC)
    if beaver_env.get("THROUGHPUT_TEST").lower() == "true":
        status = os.system("unset SPARK_HOME;cd " + script_folders + ";bash run_" + workload + "_sparksql_throughput_test.sh " + str(iteration) + " " + arrow_format)
    else:
        status = os.system("unset SPARK_HOME;cd " + script_folders + ";bash run_" + workload + "_sparkshell.sh " + str(iteration))
    log_folder = os.path.join(script_folders, workload+ "/logs")
    result_folder = os.path.join(beaver_env.get("BEAVER_OPT_HOME"), "result/" + workload + "/logs-" + str(time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())))
    os.system("mkdir -p " + result_folder)
    os.system("cp -rf " + log_folder + "/* " + result_folder)
    return status

def gen_tpc_data(beaver_env, workload):
    script_folders = os.path.join(beaver_env.get("SPARK_SQL_PERF_HOME"), workload + "_script")
    print(colors.LIGHT_BLUE + "\tStart to generate " + workload + " data..." + colors.ENDC)
    os.system("unset SPARK_HOME;cd " + script_folders + ";bash run_" + workload + "_datagen.sh")

def copy_tpcds_test_script(custom_conf, beaver_env, test_mode=[]):
    script_folder = os.path.join(tool_path, "tpcds/tpcds_script")
    dst_path = os.path.join(beaver_env.get("SPARK_SQL_PERF_HOME"), "tpcds_script")
    dict = gen_test_dict(custom_conf, beaver_env, test_mode)
    print (colors.LIGHT_BLUE + "\tCopy tpcds script ..." + colors.ENDC)
    copy_spark_test_script_to_remote(script_folder, dst_path, dict)
    sql_tar_name = "tpcds99queries.tar.gz"
    sql_tar_folder = os.path.join(dst_path, "tpcds/tpcds-queries")
    mkdirs(sql_tar_folder)
    os.system("tar -C " + sql_tar_folder +" -xf " + os.path.join(sql_tar_folder, sql_tar_name))
    os.system("rm -f " + os.path.join(sql_tar_folder, sql_tar_name))

def copy_tpch_test_script(custom_conf, beaver_env, test_mode=[]):
    script_folder = os.path.join(tool_path, "tpch/tpch_script")
    dst_path = os.path.join(beaver_env.get("SPARK_SQL_PERF_HOME"), "tpch_script")
    dict = gen_tpch_test_dict(custom_conf, beaver_env, test_mode)
    print (colors.LIGHT_BLUE + "\tCopy tpch script to ..." + colors.ENDC)
    copy_spark_test_script_to_remote(script_folder, dst_path, dict)
    sql_tar_name = "tpch22queries.tar.gz"
    sql_tar_folder = os.path.join(dst_path, "tpch/tpch-queries")
    os.system("tar -C " + sql_tar_folder + " -xf " + os.path.join(sql_tar_folder, sql_tar_name))
    os.system("rm -f " + os.path.join(sql_tar_folder, sql_tar_name))

def gen_test_dict(custom_conf ,beaver_env, mode=[]):
    dict = {};
    output_conf_dir = update_conf(TPCDS_COMPONENT, custom_conf)
    tpc_ds_config_file = os.path.join(output_conf_dir, "config")
    config_dict = get_configs_from_properties(tpc_ds_config_file)
    data_scale = config_dict.get("scale").strip()
    data_format = config_dict.get("format").strip()
    tables_partition = config_dict.get("partitionTables").strip()
    queries = config_dict.get("queries").strip()
    s3_bucket = beaver_env.get("S3_BUCKET")
    dict["{%partitionTables%}"] = tables_partition
    dict["{%scale%}"] = data_scale
    dict["{%data.format%}"] = data_format
    dict["{%spark.home%}"] = beaver_env.get("SPARK_HOME")#os.path.join(beaver_env.get("BEAVER_OPT_HOME"), "spark-" + spark_version)
    dict["{%sparksql.perf.home%}"] = beaver_env.get("SPARK_SQL_PERF_HOME")
    dict["{%tpcds.script.home%}"] = os.path.join(beaver_env.get("SPARK_SQL_PERF_HOME"), "tpcds_script/")
    dict["{%hostname%}"] = socket.gethostname()
    dict["{%tpcds.home%}"] = beaver_env.get("TPCDS_KIT_HOME")
    dict["{%storage%}"] = beaver_env.get("STORAGE")

    if beaver_env.get("NATIVE_SQL_ENGINE").lower() == "true":
        dict["{%arrow_enable%}"] = 'true'
    else:
        dict["{%arrow_enable%}"] = 'false'

    if beaver_env.get("STORAGE") == "s3":
        dict["{%s3.bucket%}"] = s3_bucket
    else:
        dict["{%s3.bucket%}"] = ""

    if config_dict.get("partitionTables").strip() == "true":
        dict["{%partitioned%}"] = "_partition"
    else:
        dict["{%partitioned%}"] = ""

    if queries == 'all':
        dict["{%queries%}"] = ""
        for i in range(1, 100):
            dict["{%queries%}"] = dict["{%queries%}"] + str(i) + " "
    else:
        dict["{%queries%}"] = queries.replace(",", " ")

    for key, val in dict.items():
        if val == None:
            dict[key] = ""
    return dict

def gen_tpch_test_dict(custom_conf ,beaver_env, mode=[]):
    dict = {};
    output_conf_dir = update_conf(TPCH_COMPONENT, custom_conf)
    tpc_h_config_file = os.path.join(output_conf_dir, "config")
    config_dict = get_configs_from_properties(tpc_h_config_file)
    data_scale = config_dict.get("scale").strip()
    data_format = config_dict.get("format").strip()
    ifPartitioned = config_dict.get("partitionTables").strip()
    tables_partition = config_dict.get("partition").strip()
    queries = config_dict.get("queries").strip()
    s3_bucket = beaver_env.get("S3_BUCKET")
    dict["{%partitionTables%}"] = ifPartitioned
    dict["{%scale%}"] = data_scale
    dict["{%data.format%}"] = data_format
    dict["{%partition%}"] = tables_partition
    dict["{%spark.home%}"] = beaver_env.get("SPARK_HOME")#os.path.join(beaver_env.get("BEAVER_OPT_HOME"), "spark-" + spark_version)
    dict["{%sparksql.perf.home%}"] = beaver_env.get("SPARK_SQL_PERF_HOME")
    dict["{%tpch.script.home%}"] = os.path.join(beaver_env.get("SPARK_SQL_PERF_HOME"), "tpch_script/")#os.path.join(beaver_env.get("OAP_HOME"), "test_script/" + spark_version)
    dict["{%hostname%}"] = socket.gethostname()
    dict["{%tpch.home%}"] = beaver_env.get("TPCH_DBGEN_HOME")
    dict["{%storage%}"] = beaver_env.get("STORAGE")

    if beaver_env.get("NATIVE_SQL_ENGINE").lower() == "true":
        dict["{%arrow_enable%}"] = 'true'
    else:
        dict["{%arrow_enable%}"] = 'false'

    if beaver_env.get("STORAGE") == "s3":
        dict["{%s3.bucket%}"] = s3_bucket
    else:
        dict["{%s3.bucket%}"] = ""

    if config_dict.get("partitionTables").strip() == "true":
        dict["{%partitioned%}"] = "_partition"
    else:
        dict["{%partitioned%}"] = ""

    if queries == 'all':
        dict["{%queries%}"] = ""
        for i in range(1, 23):
            dict["{%queries%}"] = dict["{%queries%}"] + str(i) + " "
    else:
        dict["{%queries%}"] = queries.replace(",", " ")

    for key, val in dict.items():
        if val == None:
            dict[key] = ""

    return dict

def clean_spark_sql_perf():
    os.system("rm -rf /opt/benchmark-tools/spark-sql-perf/tpcds_script")
    os.system("rm -rf /opt/benchmark-tools/spark-sql-perf/tpch_script")
