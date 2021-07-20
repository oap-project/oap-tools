import os
import sys
current_path = os.path.dirname(os.path.abspath(__file__))
project_path = os.path.dirname(current_path)
sys.path.append(project_path)
from utils.run_workflow_utils import *


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='manual to this script')
    parser.add_argument('--workflows', type=str, default="")
    args = parser.parse_args()
    workflows = args.workflows.strip().strip("\n").split(",")
    if len(workflows) == 0:
        print("Please input right workflow")
        exit(1)
    for workflow in workflows:
        run_workflow(os.path.abspath(workflow))
