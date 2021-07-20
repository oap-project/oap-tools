import collections
import os
import sys
import csv
import socket

def parseFile(fileName):
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

if __name__ == '__main__':
    args = sys.argv
    if(len(args) < 4):
        exit(1)
    resOldList = [parseFile(args[i]) for i in range(1, len(args) - 2)]
    resNew = parseFile(args[-2])
    queries_list = getQueryList(args[-2])


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
	    <title>TPCDS Benchmark Test Result</title>
	    <meta charset="utf-8">
    </head>
    <body>
        <p>Result paths are:<br> (1){} <br> (2){}</p>
        {}
    </body>
    </html>
    """
    htmlTables = ""

    suiteTable = """<table class="tg">\n"""
    suiteTable += """<tr>\n<th class="tg-yw41"></th>\n"""
    suiteTable += """<th class="tg-yw41" colspan="{}">Result of {}/ms</th>\n""".format(len(resNew["query"]), os.path.basename(args[-2].strip("/")))
    for i in range(1, len(args) - 2):
        suiteTable += """<th class="tg-yw41" colspan="{}">Result of {}/ms</th>\n""".format(len(resOldList[i - 1]["query"]), os.path.basename(args[i]))
    suiteTable += """<th class="tg-yw4l" colspan="2"></th>\n</tr>\n"""

    suiteTable += """<tr>\n<td class="tg-yw41">query</td>\n"""
    for round in resNew["query"]:
        suiteTable += """<td class="tg-yw41">{}/s</td>\n""".format(round)
    for i in range(1, len(args) - 2):
        for round in resOldList[i - 1]["query"]:
            suiteTable += """<td class="tg-yw41">{}/s</td>\n""".format(round)
    suiteTable += """<td class="tg-yw4l">regression</td>\n"""
    suiteTable += """<td class="tg-yw4l">%growth</td>\n</tr>\n"""



    for query in queries_list:
        suiteTable += """<tr>\n<td class="tg-yw41">{}</td>\n""".format(query)
        for runtime in resNew[query]:
            if int(runtime) > 0:
                suiteTable += """<td class="tg-yw41">{}</td>\n""".format(int(runtime))
            else:
                suiteTable += """<td class="tg-yw41" bgcolor="#FF0000">{}</td>\n""".format(abs(int(runtime)))
        new_average_time = int(resNew[query][len(resNew[query]) - 1])
        old_total_time = 0
        for i in range(1, len(args) - 2):
            for runtime in resOldList[i - 1][query]:
                if int(runtime) > 0:
                    suiteTable += """<td class="tg-yw41">{}</td>\n""".format(int(runtime))
                else:
                    suiteTable += """<td class="tg-yw41" bgcolor="#FF0000">{}</td>\n""".format(abs(int(runtime)))
            old_total_time = int(resOldList[i - 1][query][len(resOldList[i - 1][query]) - 1])
        old_average_time = old_total_time / (len(args) - 3)
        if old_average_time < new_average_time:
            suiteTable += """<td class="tg-yw41" bgcolor="#FF0000">Yes</td>\n"""
        else:
            suiteTable += """<td class="tg-yw41">No</td>\n"""
        suiteTable += """<td class="tg-yw41">{}</td>\n</tr>\n""".format((new_average_time - old_average_time) / float(old_average_time) * 100)

    suiteTable += "</table>\n"
    htmlTables += "\n{}\n".format(suiteTable)
    cmpFile = open(args[-1], mode='w')
    cmpFile.write(htmlContent.format(socket.gethostname() + ":" + os.path.abspath(args[-3]), socket.gethostname() + ":" + os.path.abspath(args[-2]), htmlTables))
    cmpFile.close()
