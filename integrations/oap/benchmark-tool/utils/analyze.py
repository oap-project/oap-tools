import collections
import os
import sys
import csv
import time
import re
from config_utils import *
from util import *
from run_workflow_utils import *


def write_new_result_metadata(path, new_result):
    with open(path, "w") as f:
        f.write(new_result)
        f.close

def parseTpcCsvFile(fileName):
    suitesNames = {}
    with open(os.path.join(fileName, "logs/final_result.csv"), 'rb') as f:
        csv_read = csv.reader(f)
        for line in csv_read:
            for i in range(1, len(line)):
                if not suitesNames.has_key(line[0]):
                    suitesNames[line[0]] = [line[i]]
                else:
                    suitesNames[line[0]].append(line[i])
    return suitesNames

def getQueryList(fileName):
    queries_list = []
    with open(os.path.join(fileName, "logs/final_result.csv"), 'rb') as f:
        csv_read = csv.reader(f)
        for line in csv_read:
            if not line[0] == "query":
                queries_list.append(line[0])
    return queries_list


def check_baseline_dict(output_html_file):
    if "baseline-summary" in output_html_file:
        return True
    else:
        return False

def check_last_version_baseline_dict(output_html_file):
    if "last-version-Baseline-summary" in output_html_file:
        return True
    else:
        return False

def parseOapPerfFile(fileName):
    file = open(os.path.join(fileName, "oap_perf_suite_result/testres"))
    suitesLines = []
    suitesNames = []
    totalLines = 0
    res = {}
    for i, line in enumerate(file.readlines()):
        totalLines += 1
        if (line.startswith("#")):
            suitesLines.append(i + 1)
            suitesNames.append(line)
    suitesLines.append(totalLines)
    file.seek(0)
    lines = file.readlines()
    for i in range(len(suitesNames)):
        tpres = {}
        suiteStart = suitesLines[i]
        while (suiteStart < suitesLines[i + 1] - 1):
            suiteStart += 2
            caseName = lines[suiteStart - 1].split("|")[1].lstrip()
            suiteStart += 2
            tpres[caseName] = {}
            while (lines[suiteStart - 1].startswith("|")):
                median = int(lines[suiteStart - 1].split("|")[-2].lstrip())
                configName = lines[suiteStart - 1].split("|")[1].lstrip()
                suiteStart += 1
                tpres[caseName][configName] = median
        res[suitesNames[i]] = tpres
    return res

def parseHibenchFile(fileName):
    parsedResult = {}
    with open(os.path.join(fileName, "report/hibench.report"), 'r') as f:
        performance_datas = f.readlines()
        if len(performance_datas) < 2:
            print("No data in this hibench.report")
            return 1
        parsedResult["titles"] = re.sub('  +', ' ', performance_datas[0].strip()).split(" ")
        parsedResult["valueLists"] = []
        for index in range(len(performance_datas)):
            if index == 0:
                continue
            parsedResult["valueLists"].append(re.sub('  +', ' ', performance_datas[1].strip()).split(" "))
    return parsedResult

def get_degradation_ratio(resNew, resOldList):
    result_degradation_summary = {}
    runtime = float(resNew["valueLists"][0][4].strip("/s"))
    old_result_number = 0
    total_old_result_time = 0
    for resOld in resOldList:
        total_old_result_time += float(resOld["valueLists"][0][4].strip("/s"))
        old_result_number += 1
    average_old_result = total_old_result_time / old_result_number
    degradation_ration = (1.0 / runtime - 1.0 / average_old_result) / (1.0 / average_old_result)
    result_degradation_summary["degradation_ration"] = degradation_ration
    return result_degradation_summary


def get_hibench_summary_result(last_result, new_result, workflow, workflow_result_dict, workflow_start_date, html_name="result.html"):
    conf = os.path.dirname(new_result)
    beaver_env = get_merged_env(conf)
    res = {}
    res["component"] = os.path.basename(os.path.dirname(conf))
    res["configuration"] = os.path.basename(os.path.dirname(new_result))
    resOldList = [parseHibenchFile(last_result)]
    resNew = parseHibenchFile(new_result)
    res["status"] = "SUCCEED"
    res["failed_cases"] = 0
    res["succeeded_cases"] = 1
    res["this_total_time"] = resNew["valueLists"][0][4].strip("/s")
    total_old_result_time = 0
    old_result_number = 0
    for resOld in resOldList:
        total_old_result_time += float(resOld["valueLists"][0][4].strip("/s"))
        old_result_number += 1

    res["pre_total_time"] = total_old_result_time / old_result_number
    result_degradation_summary = get_degradation_ratio(resNew, resOldList)
    if result_degradation_summary["degradation_ration"] < -0.05:
        res["degradation"] = 1
    else:
        res["degradation"] = 0
    res["degradation_ratio"] = round(result_degradation_summary["degradation_ration"], 3) * 100

    result_history_url = get_result_history_url(workflow, workflow_start_date, new_result)
    res["details"] = os.path.join(result_history_url, html_name)
    workflow_result_dict[os.path.basename(conf)] = res
    if html_name == "result.html":
        write_new_result_metadata(os.path.join(os.path.dirname(new_result), "last_test_info"), new_result)


def analyze_hibench_result(last_result, new_result, output_html_file, workflow, workflow_start_date):
    resOldList = [parseHibenchFile(last_result)]
    resNew = parseHibenchFile(new_result)

    htmlContent = """
        <!DOCTYPE html>
        <html>
        <style type="text/css">
            .tg {{border-collapse:collapse;border-spacing:0;}}
            .tg td {{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
            .tg th {{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
            .tg .tg-y2tu {{font-weight:bold;text-decoration:underline;vertical-align:top}}
            .tg .tg-baqh {{text-align:center;vertical-align:top}}
            .tg .tg-lqy6 {{text-align:right;vertical-align:top}}
            .tg .tg-yw4l {{vertical-align:top}}
            .tg .tg-ahyg {{font-weight:bold;background-color:#fe0000;vertical-align:top}}
        </style>
        <head>
    	    <title>HiBench Test Result</title>
    	    <meta charset="utf-8">
        </head>
        <body>
            <p>Result paths are:<br> <a href={}> (1){} </a> <br> <a href={}> (2){} </a></p>
            {}
        </body>
        </html>
        """
    htmlTables = ""

    suiteTable = """<table class="tg">\n"""
    # title
    suiteTable += """<tr>\n"""
    for title in resNew["titles"]:
        suiteTable += """<td class="tg-yw41">{}</td>\n""".format(title)
    suiteTable += """</tr>\n"""

    # resOldList value
    for resOld in resOldList:
        for valueList in resOld["valueLists"]:
            suiteTable += """<tr>\n"""
            for value in valueList:
                suiteTable += """<td class="tg-yw41">{}</td>\n""".format(value)
            suiteTable += """</tr>\n"""
    # resNew value
    for valueList in resNew["valueLists"]:
        suiteTable += """<tr>\n"""
        for value in valueList:
            suiteTable += """<td class="tg-yw41">{}</td>\n""".format(value)
        suiteTable += """</tr>\n"""

    suiteTable += "</table>\n"
    htmlTables += "\n{}\n".format(suiteTable)
    last_result_date = os.path.basename(last_result).split("_")[-3]
    cmpFile = open(output_html_file, mode='w')
    cmpFile.write(htmlContent.format(
        get_result_history_url(workflow, last_result_date, last_result),
        os.path.basename(last_result),
        get_result_history_url(workflow, workflow_start_date, new_result),
        os.path.basename(new_result), htmlTables))
    cmpFile.close()

def get_tpc_failed_queries(res):
    failed_queries = {}
    failed_queries["number"] = 0
    failed_queries["queries"] = ""
    for query in res.keys():
        if query == "total" or query == "query":
            continue
        for value in res[query]:
            if float(value) <= 0:
                failed_queries["number"] += 1
                failed_queries["queries"] += (query + ",")
                break
    failed_queries["queries"].strip(",")
    return failed_queries

def get_queries_avg(res):
    res_average_time = {}
    for query in  res:
        if query == "query":
            continue
        res_average_time[query] = float(res[query][-1])
        for value in res[query]:
            if float(value) < 0:
                del res_average_time[query]
                break
    return res_average_time


def get_tpc_degradation_queries(resOld, resNew):
    degradation_queries = {}
    degradation_queries["number"] = 0
    degradation_queries["queries"] = ""
    resOld_average_time = get_queries_avg(resOld)
    resNew_average_time = get_queries_avg(resNew)
    degradation_queries["total"] = False
    for query in resNew_average_time.keys():
        if resOld_average_time.has_key(query) and (1.0 / resNew_average_time[query] - 1.0 / resOld_average_time[query]) / (1.0 / resOld_average_time[query]) < -0.05:
            if query == "total":
                degradation_queries["total"] = True
                degradation_queries["degradation_ration"] = (1.0 / resNew_average_time[query] - 1.0 / resOld_average_time[query]) / (1.0 / resOld_average_time[query])
                continue
            degradation_queries["number"] += 1
            degradation_queries["queries"] += (query + ",")

    degradation_queries["queries"].strip(",")
    return degradation_queries


def get_tpc_summary_result(last_result, new_result, workflow, workflow_result_dict, workflow_start_date, html_name="result.html"):
    res = {}
    res["component"] = os.path.basename(os.path.dirname(os.path.dirname(new_result)))
    res["configuration"] = os.path.basename(os.path.dirname(new_result))
    conf = os.path.dirname(new_result)
    beaver_env = get_merged_env(conf)
    resNew = parseTpcCsvFile(new_result)
    resOld = parseTpcCsvFile(last_result)
    failed_queries_num = 0
    if beaver_env.get("THROUGHPUT_TEST").lower() == "true":
        new_status = "SUCCEED"
        old_status = "SUCCEED"
        for stream in resNew:
            if resNew[stream][-1] == "Fail":
                new_status = "FAILED"
                break
        for stream in resOld:
            if resOld[stream][-1] == "Fail":
                old_status = "FAILED"
                break
        res["status"] = new_status
        if new_status == "SUCCEED":
            res["failed_cases"] = 0
            res["succeeded_cases"] = 1
            res["this_total_time"] = resNew["total"][0]
            if old_status == "SUCCEED":
                res["pre_total_time"] = resOld["total"][0]
                ratio = (1.0 / float(resNew["total"][0]) - 1.0 / float(resOld["total"][0])) / (
                        1.0 / float(resOld["total"][0]))
                res["degradation_ratio"] = round(ratio, 3) * 100
                if ratio < -0.05:
                    res["degradation"] = 1
                else:
                    res["degradation"] = 0
            else:
                res["pre_total_time"] = "X"
                res["degradation_ratio"] = "X"
                res["degradation"] = "X"
        else:
            res["failed_cases"] = 1
            res["succeeded_cases"] = 0
            res["this_total_time"] = "X"
            if old_status == "SUCCEED":
                res["pre_total_time"] = resOld["total"][0]
            else:
                res["pre_total_time"] = "X"
            res["degradation_ratio"] = "X"
            res["degradation"] = "X"
    else:
        queries_list = getQueryList(new_result)
        failed_queries_message = get_tpc_failed_queries(resNew)
        failed_queries_num = failed_queries_message["number"]
        if failed_queries_num != 0:
            res["status"] = "FAILED"
        else:
            res["status"] = "SUCCEED"
        total_queries_num = len(queries_list) - 1
        failed_queries_num = failed_queries_message["number"]
        res["failed_cases"] = failed_queries_num
        success_queries_num = total_queries_num - failed_queries_num
        res["succeeded_cases"] = success_queries_num
        resOld_average_time = get_queries_avg(resOld)
        resNew_average_time = get_queries_avg(resNew)
        if failed_queries_num == 0:
            res["this_total_time"] = resNew_average_time["total"]
        else:
            res["this_total_time"] = "X"
        if get_tpc_failed_queries(resOld)["number"] == 0:
            res["pre_total_time"] = resOld_average_time["total"]
        else:
            res["pre_total_time"] = "X"

        if failed_queries_num == 0 and get_tpc_failed_queries(resOld)["number"] == 0:
            ratio = (1.0 / float(resNew["total"][-1]) - 1.0 / float(resOld["total"][-1])) / (
                        1.0 / float(resOld["total"][-1]))
            res["degradation_ratio"] = round(ratio, 3) * 100
        else:
            res["degradation_ratio"] = "X"

        if failed_queries_num == 0 and get_tpc_failed_queries(resOld)["number"] == 0:
            degradation_queries_message = get_tpc_degradation_queries(resOld, resNew)
            degradation_queries_num = degradation_queries_message["number"]
            if degradation_queries_num > 0:
                res["degradation"] = degradation_queries_num
            else:
                res["degradation"] = 0
        else:
            res["degradation"] = "X"

    result_history_url = get_result_history_url(workflow, workflow_start_date, new_result)
    res["details"] = os.path.join(result_history_url, html_name)
    workflow_result_dict[os.path.basename(conf)] = res
    if failed_queries_num == 0 and html_name == "result.html":
        write_new_result_metadata(os.path.join(os.path.dirname(new_result), "last_test_info"), new_result)

def get_common_list(list1, list2):
    common_list = []
    for value in list1:
        if value in list2:
            common_list.append(value)
    return common_list


def analyze_tpc_result(last_result, new_result, output_html_file, workflow, workflow_start_date):
    htmlContent = """
            <!DOCTYPE html>
            <html>
            <style type="text/css">
                .tg {{border-collapse:collapse;border-spacing:0;width:1000px;table-layout:fixed}}
                .tg td {{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
                .tg th {{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
                .tg .tg-y2tu {{font-weight:bold;text-decoration:underline;vertical-align:top}}
                .tg .tg-baqh {{text-align:center;vertical-align:top}}
                .tg .tg-lqy6 {{text-align:right;vertical-align:top}}
                .tg .tg-yw4l {{vertical-align:top}}
                .tg .tg-ahyg {{font-weight:bold;background-color:#fe0000;vertical-align:top}}
            </style>
            <head>
        	    <title>TPCDS Benchmark Test Result</title>
        	    <meta charset="utf-8">
            </head>
            <body>
                <p>Result paths are:<br> <a href={}> (1){} </a> <br> <a href={}> (2){} </a></p>
                {}
            </body>
            </html>
            """
    htmlTables = ""
    conf = os.path.dirname(new_result)
    beaver_env = get_merged_env(conf)
    if beaver_env.get("THROUGHPUT_TEST").lower() == "true":
        resOld = parseTpcCsvFile(last_result)
        resNew = parseTpcCsvFile(new_result)
        common_stream = get_common_list(resOld.keys(), resNew.keys())
        common_stream.sort()
        suiteTable = """<table class="tg" >\n"""
        suiteTable += """<tr>\n<th class="tg-yw41"></th>\n"""
        suiteTable += """<th class="tg-yw41" >Last time/s</th>\n"""
        suiteTable += """<th class="tg-yw41" >This time/s</th>\n"""
        suiteTable += """<td class="tg-yw4l">regression</td>\n"""
        suiteTable += """<td class="tg-yw4l">%growth</td>\n</tr>\n"""

        for stream in common_stream:
            old_right = True
            new_right = True
            suiteTable += """<tr>\n<td class="tg-yw41">{}</td>\n""".format(stream)

            old_total_time = float(resOld[stream][0])
            if old_total_time > 0:
                suiteTable += """<td class="tg-yw41">{}</td>\n""".format(old_total_time)
            else:
                old_right = False
                suiteTable += """<td class="tg-yw41" bgcolor="red">{}</td>\n""".format(abs(old_total_time))

            new_total_time = float(resNew[stream][0])
            if new_total_time > 0:
                suiteTable += """<td class="tg-yw41">{}</td>\n""".format(new_total_time)
            else:
                old_right = False
                suiteTable += """<td class="tg-yw41" bgcolor="red">{}</td>\n""".format(abs(new_total_time))

            if new_total_time == 0.0 or old_total_time == 0.0:
                suiteTable += """<td class="tg-yw41" bgcolor="gray">X</td>\n"""
                suiteTable += """<td class="tg-yw41">0.0</td>\n</tr>\n"""
                continue
            ratio = (1.0 / new_total_time - 1.0 / old_total_time) / (1.0 / float(old_total_time))
            if old_right:
                if new_right:
                    if ratio <= -0.15:
                        suiteTable += """<td class="tg-yw41" bgcolor="red">Yes</td>\n"""
                    elif ratio > -0.15 and ratio <= -0.05:
                        suiteTable += """<td class="tg-yw41" bgcolor="yellow">Yes</td>\n"""
                    else:
                        suiteTable += """<td class="tg-yw41" bgcolor="green">No</td>\n"""
                else:
                    suiteTable += """<td class="tg-yw41" bgcolor="gray">X</td>\n"""
            else:
                suiteTable += """<td class="tg-yw41" bgcolor="gray">X</td>\n"""
            suiteTable += """<td class="tg-yw41">{}</td>\n</tr>\n""".format(round(ratio, 3) * 100)
        suiteTable += "</table>\n"
        htmlTables += "\n{}\n".format(suiteTable)

    else:
        resOld = parseTpcCsvFile(last_result)
        resNew = parseTpcCsvFile(new_result)
        old_queries_list = getQueryList(last_result)
        new_queries_list = getQueryList(new_result)
        queries_list = get_common_list(old_queries_list, new_queries_list)

        suiteTable = """<table class="tg" >\n"""
        suiteTable += """<tr>\n<th class="tg-yw41"></th>\n"""
        suiteTable += """<th class="tg-yw41" colspan="{}">Last time</th>\n""".format(len(resOld["query"]))
        suiteTable += """<th class="tg-yw41" colspan="{}">This time</th>\n""".format(len(resNew["query"]))
        suiteTable += """<th class="tg-yw41" colspan="2"></th>\n</tr>\n"""

        suiteTable += """<tr>\n<td class="tg-yw41">query</td>\n"""
        for iteration in resOld["query"]:
            suiteTable += """<td class="tg-yw41">{}/s</td>\n""".format(iteration)
        for iteration in resNew["query"]:
            suiteTable += """<td class="tg-yw41">{}/s</td>\n""".format(iteration)
        suiteTable += """<td class="tg-yw4l">regression</td>\n"""
        suiteTable += """<td class="tg-yw4l">%growth</td>\n</tr>\n"""

        for query in queries_list:
            old_right = True
            new_right = True
            suiteTable += """<tr>\n<td class="tg-yw41">{}</td>\n""".format(query)
            for runtime in resOld[query]:
                if float(runtime) > 0:
                    suiteTable += """<td class="tg-yw41">{}</td>\n""".format(float(runtime))
                else:
                    old_right = False
                    suiteTable += """<td class="tg-yw41" bgcolor="#FF0000">{}</td>\n""".format(abs(float(runtime)))
            old_average_time = float(resOld[query][-1])
            for runtime in resNew[query]:
                if float(runtime) > 0:
                    suiteTable += """<td class="tg-yw41">{}</td>\n""".format(float(runtime))
                else:
                    new_right = False
                    suiteTable += """<td class="tg-yw41" bgcolor="red">{}</td>\n""".format(abs(float(runtime)))
            new_average_time = float(resNew[query][-1])
            if new_average_time == 0.0 or old_average_time == 0.0:
                suiteTable += """<td class="tg-yw41" bgcolor="gray">X</td>\n"""
                suiteTable += """<td class="tg-yw41">0.0</td>\n</tr>\n"""
                continue
            ratio = (1.0 / new_average_time - 1.0 / old_average_time) / (1.0 / float(old_average_time))
            if old_right:
                if new_right:
                    if ratio <= -0.15:
                        suiteTable += """<td class="tg-yw41" bgcolor="red">Yes</td>\n"""
                    elif ratio > -0.15 and ratio <= -0.05:
                        suiteTable += """<td class="tg-yw41" bgcolor="yellow">Yes</td>\n"""
                    else:
                        suiteTable += """<td class="tg-yw41" bgcolor="green">No</td>\n"""
                else:
                    suiteTable += """<td class="tg-yw41" bgcolor="gray">X</td>\n"""
            else:
                suiteTable += """<td class="tg-yw41" bgcolor="gray">X</td>\n"""
            suiteTable += """<td class="tg-yw41">{}</td>\n</tr>\n""".format(round(ratio, 3) * 100)

        suiteTable += "</table>\n"
        htmlTables += "\n{}\n".format(suiteTable)

    last_result_date = os.path.basename(last_result).split("_")[-3]
    cmpFile = open(output_html_file, mode='w')
    cmpFile.write(htmlContent.format(
        get_result_history_url(workflow, last_result_date, last_result),
        os.path.basename(last_result),
        get_result_history_url(workflow, workflow_start_date, new_result),
        os.path.basename(new_result), htmlTables))
    cmpFile.close()

def get_oap_perf_summary_result(last_result, new_result, workflow, workflow_result_dict, workflow_start_date, html_name="result.html"):
    conf = os.path.dirname(new_result)
    beaver_env = get_merged_env(conf)
    res = {}
    res["component"] = os.path.basename(os.path.dirname(conf))
    res["configuration"] = os.path.basename(os.path.dirname(new_result))
    resOldList = [parseOapPerfFile(last_result)]
    resNew = parseOapPerfFile(new_result)
    res["status"] = "SUCCEED"
    res["failed_cases"] = 0

    baseNameList = []
    baseNameList.append(os.path.basename(last_result))
    baseNameList.append(os.path.basename(new_result))
    regression_case = 0
    total_case = 0
    pre_total_time = 0
    this_total_time = 0

    for suiteRes in resNew:
        for caseName in resNew[suiteRes]:
            total_case += len(resNew[suiteRes][caseName])
            for config in resNew[suiteRes][caseName]:
                this_total_time += resNew[suiteRes][caseName][config]

    resLastday = resOldList[-1]
    for suiteRes in resLastday:
        for caseName in resLastday[suiteRes]:
            total_case += len(resLastday[suiteRes][caseName])
            for config in resLastday[suiteRes][caseName]:
                pre_total_time += resLastday[suiteRes][caseName][config]

    for suite, suiteRes in resNew.items():
        for case, caseRes in suiteRes.items():
            j = 0
            odRes = collections.OrderedDict(sorted(caseRes.items()))
            for config, median in odRes.items():
                resLastday = resOldList[-1]
                if (suite in resLastday and case in resLastday[suite] and config in resLastday[suite][case]):
                    if (median > resLastday[suite][case][config]):
                        if (resLastday[suite][case][config] != 0):
                            per = (1.0 / median - 1.0 / resLastday[suite][case][config]) / (1.0 / resLastday[suite][case][config])
                            if (per < -0.05):
                                regression_case += 1
                        else:
                            regression_case += 1
                j += 1

    res["succeeded_cases"] = total_case
    if regression_case > 0:
        res["degradation"] = regression_case
    else:
        res["degradation"] = 0

    res["this_total_time"] = this_total_time / 1000.0
    res["pre_total_time"] = pre_total_time / 1000.0
    ratio = (1.0 / this_total_time - 1.0 / pre_total_time) / (1.0 / pre_total_time)
    res["degradation_ratio"] = round(ratio,3) * 100

    result_history_url = get_result_history_url(workflow, workflow_start_date, new_result)
    res["details"] = os.path.join(result_history_url, html_name)
    workflow_result_dict[os.path.basename(conf)] = res
    if  html_name == "result.html":
        write_new_result_metadata(os.path.join(os.path.dirname(new_result), "last_test_info"), new_result)


def get_result_history_url(workflow, workflow_start_date, res):
    return "http://" + os.environ.get("PACKAGE_SERVER", "10.239.44.95") + "/" + os.path.basename(
        workflow) + "/" + workflow_start_date + "/" + os.path.basename(res)

def analyze_oap_perf_result(last_result, new_result, output_html_file, workflow, workflow_start_date):
    resOldList = [parseOapPerfFile(last_result)]
    resNew = parseOapPerfFile(new_result)
    baseNameList = []
    baseNameList.append(os.path.basename(last_result))
    baseNameList.append(os.path.basename(new_result))
    # baseNameList = [os.path.basename(args[i])[8:] for i in range(1, len(args) - 1)]
    htmlContent = """
        <!DOCTYPE html>
        <html>
        <style type="text/css">
            .tg {{border-collapse:collapse;border-spacing:0;}}
            .tg td {{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
            .tg th {{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
            .tg .tg-y2tu {{font-weight:bold;text-decoration:underline;vertical-align:top}}
            .tg .tg-baqh {{text-align:center;vertical-align:top}}
            .tg .tg-lqy6 {{text-align:right;vertical-align:top}}
            .tg .tg-yw4l {{vertical-align:top}}
            .tg .tg-ahyg {{font-weight:bold;background-color:#fe0000;vertical-align:top}}
        </style>
        <head>
    	    <title>Daily Benchmark Test Result</title>
    	    <meta charset="utf-8">
        </head>
        <body>
            <p>Result paths are:<br> <a href={}> (1){} </a>  <br> <a href={}> (2){} </a></p>
            {}
        </body>
        </html>
        """
    htmlTables = ""
    cellFormat = """<td class="tg-yw4l">{}</td>\n"""
    colorFormat = """<td class="tg-ahyg">Yes</td>\n"""
    for suite, suiteRes in resNew.items():
        suiteTable = """<table class="tg">\n"""
        suiteTable += """<tr>\n<th class="tg-baqh">{}</th>\n<th class="tg-yw4l">Config</th>\n""".format(suite)
        for baseName in baseNameList:
            suiteTable += """<th class="tg-yw41">Result of {}/ms</th>\n""".format(baseName)
        suiteTable += """<th class="tg-yw4l">Regression</th></tr>\n"""
        for case, caseRes in suiteRes.items():
            configNums = len(caseRes)
            j = 0
            odRes = collections.OrderedDict(sorted(caseRes.items()))
            for config, median in odRes.items():
                if (j == 0):
                    suiteTable += """<tr>\n<td class="tg-yw4l" rowspan="{}">{}</td>\n""".format(configNums, case)
                    suiteTable += """<td class="tg-yw4l">{}</td>\n""".format(config)
                else:
                    suiteTable += """<tr>\n<td class="tg-yw4l">{}</td>\n""".format(config)
                # currently we just compare with last day and present the others as history data for better judgement
                for res in resOldList:
                    if (suite in res and case in res[suite] and config in res[suite][case]):
                        suiteTable += cellFormat.format(res[suite][case][config])
                    else:
                        suiteTable += cellFormat.format("N/A")
                resLastday = resOldList[-1]
                suiteTable += cellFormat.format(median)
                if (suite in resLastday and case in resLastday[suite] and config in resLastday[suite][case]):
                    if (median > resLastday[suite][case][config]):
                        if (resLastday[suite][case][config] != 0):
                            per = (1.0 / median - 1.0 / resLastday[suite][case][config]) / (1.0 / resLastday[suite][case][config])
                            if (per > -0.05):
                                suiteTable += cellFormat.format("No")
                            elif (per > -0.15 and per < -0.05):
                                suiteTable += """<td class="tg-yw4l" bgcolor="yellow">Yes</td>\n"""
                            else:
                                suiteTable += colorFormat
                        else:
                            suiteTable += colorFormat
                    else:
                        suiteTable += cellFormat.format("No")
                else:
                    suiteTable += cellFormat.format("N/A")
                suiteTable += "</tr>\n"
                j += 1
        suiteTable += "</table>\n"
        htmlTables += "\n{}\n".format(suiteTable)
    last_result_date = os.path.basename(last_result).split("_")[-3]
    cmpFile = open(output_html_file, mode='w')
    cmpFile.write(htmlContent.format(
        get_result_history_url(workflow, last_result_date, last_result),
        os.path.basename(last_result),
        get_result_history_url(workflow, workflow_start_date, new_result),
        os.path.basename(new_result), htmlTables))
    cmpFile.close()

def analyze_workflow_result(workflow, workflow_result_dict, workflow_start_date, output_html_file):
    output_workflow = os.path.join(workflow, "output/output_workflow")
    testing_conf_list = []
    get_conf_list(output_workflow, testing_conf_list, [])
    beaver_env = get_merged_env(testing_conf_list[0])
    REGRESSION_CHECK = beaver_env.get("REGRESSION_CHECK").lower()
    BASELINE_COMP = beaver_env.get("BASELINE_COMP").lower()
    htmlContent = """
            <!DOCTYPE html>
            <html>
            <style type="text/css">
                .tg {{border-collapse:collapse;border-spacing:0;}}
                .tg td {{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
                .tg th {{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}}
                .tg .tg-y2tu {{font-weight:bold;text-decoration:underline;vertical-align:top}}
                .tg .tg-baqh {{text-align:center;vertical-align:top}}
                .tg .tg-lqy6 {{text-align:right;vertical-align:top}}
                .tg .tg-yw4l {{vertical-align:top}}
                .tg .tg-ahyg {{font-weight:bold;background-color:#fe0000;vertical-align:top}}
            </style>
            <head>
        	    <title>Workflow Result Sumary</title>
        	    <meta charset="utf-8">
            </head>
            <body>             
                {}
                <p class="tg-baqh"><a href={}> Click here to see detailed logs for {}</a> </p>
            </body>
            </html>
            """
    htmlTables = ""
    head = """<th class="tg-yw41" align="center" bgcolor="#3104B4">{}</th>\n"""
    cell = """<td class="tg-baqh">{}</td>\n"""
    cell_RED = """<td class="tg-baqh" style="color: red">{}</td>\n"""
    cell_YELLOW = """<td class="tg-baqh" style="color: #D7DF01">{}</td>\n"""
    cell_GREEN = """<td class="tg-baqh" style="color: green">{}</td>\n"""

    suiteTable = """<table class="tg">\n"""
    suiteTable += """<tr>\n"""
    suiteTable += head.format("Component")
    suiteTable += head.format("Configuration")
    suiteTable += head.format("Status")
    suiteTable += head.format("Succeeded Cases")
    suiteTable += head.format("Failed cases")
    if BASELINE_COMP == "true" and check_baseline_dict(output_html_file):
        suiteTable += head.format("Baseline time/s")
        suiteTable += head.format("Optimized time/s")
    elif BASELINE_COMP == "true" and check_last_version_baseline_dict(output_html_file):
        suiteTable += head.format("Previous_Version time/s")
        suiteTable += head.format("Current_Version time/s")
    else:
        suiteTable += head.format("Previous time/s")
        suiteTable += head.format("This time/s")
    if REGRESSION_CHECK == "true":
        if BASELINE_COMP == "true" and check_baseline_dict(output_html_file):
            suiteTable += head.format("Performance gain/%")
        else:
            suiteTable += head.format("Regression ratio/%")
            suiteTable += head.format("Regression cases")
    suiteTable += head.format("Details")
    suiteTable += """</tr>\n"""
    for conf in collections.OrderedDict(sorted(workflow_result_dict.items())).keys():
        suiteTable += """<tr>\n"""
        suiteTable += cell.format(workflow_result_dict[conf]["component"])
        suiteTable += cell.format(workflow_result_dict[conf]["configuration"])
        if workflow_result_dict[conf]["status"] == "SUCCEED":
            suiteTable += cell_GREEN.format(workflow_result_dict[conf]["status"])
        else:
            suiteTable += cell_RED.format(workflow_result_dict[conf]["status"])
        suiteTable += cell_GREEN.format(workflow_result_dict[conf]["succeeded_cases"])
        if workflow_result_dict[conf]["failed_cases"] !="X"and workflow_result_dict[conf]["failed_cases"] > 0:
            suiteTable += cell_RED.format(workflow_result_dict[conf]["failed_cases"])
        else:
            suiteTable += cell.format(workflow_result_dict[conf]["failed_cases"])
        suiteTable += cell.format(workflow_result_dict[conf]["pre_total_time"])
        suiteTable += cell.format(workflow_result_dict[conf]["this_total_time"])

        if REGRESSION_CHECK == "true":
            ratio = workflow_result_dict[conf]["degradation_ratio"]
            if ratio != "X" and ratio <= -15:
                suiteTable += cell_RED.format(ratio)
            elif ratio != "X" and ratio <= -5 and ratio > -15:
                suiteTable += cell_YELLOW.format(ratio)
            else:
                suiteTable += cell_GREEN.format(ratio)
            if BASELINE_COMP != "true" or not check_baseline_dict(output_html_file):
                if workflow_result_dict[conf]["degradation"] == "X":
                    suiteTable += cell.format(workflow_result_dict[conf]["degradation"])
                elif workflow_result_dict[conf]["degradation"] == 0:
                    suiteTable += cell_GREEN.format(workflow_result_dict[conf]["degradation"])
                else:
                    suiteTable += cell_RED.format(workflow_result_dict[conf]["degradation"])
        suiteTable += """<td class="tg-baqh" ><a href={}> Details</a> </td>\n""".format(workflow_result_dict[conf]["details"])
        suiteTable += """</tr>\n"""
    suiteTable += "</table>\n"
    htmlTables += "\n{}\n".format(suiteTable)
    cmpFile = open(output_html_file, mode='w')
    cmpFile.write(htmlContent.format(htmlTables, get_result_history_url(workflow, workflow_start_date, ""),
                                     os.path.basename(workflow)))
    cmpFile.close()
