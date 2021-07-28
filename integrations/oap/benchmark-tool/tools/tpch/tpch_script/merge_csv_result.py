import csv
import sys
import os

def create_result_csv(root_path):
    queries_result = {}
    queries_list = []
    total_result = []

    # read log result
    for dir in os.listdir(root_path):
        if os.path.isdir(os.path.join(root_path, dir)):
            with open(os.path.join(os.path.join(root_path, dir), "result.csv"), 'rb') as f:
                csv_read = csv.reader(f)
                total_time_per_round = 0
                for line in csv_read:
                    total_time_per_round = total_time_per_round + float(line[1])
                    if not queries_result.has_key(line[0]) and line[0] is not "":
                        if line[2] == "Success":
                            queries_result[line[0]] = [line[1]]
                        else:
                            queries_result[line[0]] = ["-" + line[1]]
                        queries_list.append(line[0])
                    else:
                        if line[2] == "Success":
                            queries_result[line[0]].append(line[1])
                        else:
                            queries_result[line[0]].append("-" + line[1])

                total_result.append(total_time_per_round)

    # add all results into one file
    final_result_file = os.path.join(root_path, "final_result.csv")
    with open(final_result_file,'wb') as f:
        csv_write = csv.writer(f)
        csv_head = ["query"]
        csv_tail = ["total"]
        for dir in os.listdir(root_path):
            if os.path.isdir(os.path.join(root_path, dir)):
                csv_head.append(dir)
        csv_head.append("average")
        csv_write.writerow(csv_head)
        average_time_per_round = 0
        for query in queries_list:
            line = []
            total_time_per_query = 0
            line.append(query)
            for runtime in queries_result.get(query):
                line.append(runtime)
                total_time_per_query = total_time_per_query + abs(float(runtime))
            if len(line) == 2:
                average_time_per_query = total_time_per_query / (len(line) - 1)
            else:
                average_time_per_query = (total_time_per_query - abs(float(line[1]))) / (len(line) - 2)
            average_time_per_round = average_time_per_round + average_time_per_query
            line.append(average_time_per_query)
            csv_write.writerow(line)

        for total_time_per_round in total_result:
            csv_tail.append(total_time_per_round)
        csv_tail.append(average_time_per_round)
        csv_write.writerow(csv_tail)

if __name__ == '__main__':
    args = sys.argv
    if len(args) < 2:
        exit(1)
    result_path = args[1]
    create_result_csv(result_path)