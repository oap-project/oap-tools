import os
import sys
current_path = os.path.dirname(os.path.abspath(__file__))
project_path = os.path.dirname(current_path)
sys.path.append(project_path)

from utils.config_utils import *
from utils.fileRoot import *
from utils.colors import *
from util import *


def update_workflow(conf_root):
    workflow_output = os.path.join(conf_root, "output")
    current_workflow = os.path.join(workflow_output, "output_workflow")
    mkdirs(current_workflow)
    current_base_workflow = os.path.join(workflow_output, "output_base_workflow")
    mkdirs(current_base_workflow)
    common_conf = os.path.join(conf_root, "common")
    components_conf = os.path.join(conf_root, "components")
    meta_data = os.path.join(conf_root, ".base")
    with open(meta_data, 'r') as f:
        parent_workflow = os.path.join(conf_root,f.readlines()[0].strip())

    if os.path.exists(os.path.join(parent_workflow,".base")) and os.path.abspath(parent_workflow) != conf_root:
        update_workflow(os.path.abspath(parent_workflow))
        parent_workflow = os.path.join(os.path.join(parent_workflow, "output"),  "output_workflow")
    else:
        parent_workflow = os.path.join(os.path.join(parent_workflow, "components"))

    workflow_add_configuration(get_workflow_tree(conf_root), parent_workflow, current_base_workflow)
    copy_common_to_base_workflow(common_conf, parent_workflow, current_base_workflow)
    workflow_add_configuration(get_workflow_tree(conf_root), parent_workflow, current_workflow)
    copy_defined_configuration_to_current_workflow(components_conf, current_base_workflow, current_workflow)
    check_conf_inheritance(conf_root)

def check_conf_inheritance(conf_root):
    meta_data = os.path.join(conf_root, ".base")
    with open(meta_data, 'r') as f:
        parent_workflow = os.path.abspath(os.path.join(conf_root, f.readlines()[0].strip()))
    output_base_workflow = os.path.join(conf_root, "output/output_base_workflow")
    output_workflow = os.path.join(conf_root, "output/output_workflow")
    testing_conf_list = []
    get_all_conf_list(output_base_workflow, testing_conf_list)
    if parent_workflow == conf_root:
        common_conf = os.path.join(conf_root, "common")
        for conf in testing_conf_list:
            update_base_file(conf, common_conf)
        return

    output_base_parent_workflow = os.path.join(parent_workflow, "output/output_base_workflow")
    output_parent_workflow = os.path.join(parent_workflow, "output/output_workflow")
    for conf in testing_conf_list:
        relative_path = os.path.relpath(conf, output_base_workflow)
        if not os.path.exists(os.path.join(output_parent_workflow, relative_path)):
            parent_conf = os.path.join(output_base_parent_workflow, relative_path)
            mkdirs(parent_conf)
            if not os.path.exists(os.path.join(parent_conf, ".base")):
                os.system("touch " + os.path.join(parent_conf, ".base"))
            update_base_file(conf, parent_conf)
            os.system("cp -r " + os.path.join(parent_workflow, "common") + "/* " + parent_conf)
    check_conf_inheritance(parent_workflow)

def copy_defined_configuration_to_current_workflow(conf_root, current_base_workflow, current_workflow):
    for dir in os.listdir(current_workflow):
        # dir is not empty or dir has not  .base file.
        if not os.path.exists(os.path.join(current_workflow, os.path.join(dir, ".base"))) and \
                not os.path.isfile(os.path.join(current_workflow, dir)) \
                and os.listdir(os.path.join(current_workflow, dir)):
            copy_defined_configuration_to_current_workflow(os.path.join(conf_root, dir),
                                                           os.path.join(current_base_workflow, dir), os.path.join(current_workflow, dir))
        else:
            if not os.path.isfile(os.path.join(current_workflow, dir)):
                if os.path.exists(os.path.join(conf_root, dir)):
                    os.system("cp -r " + os.path.join(conf_root, dir) + "/* " + os.path.join(current_workflow, dir + "/"))
                start = os.path.join(current_workflow, dir)
                end = os.path.join(current_base_workflow, dir)
                update_base_file(start, end)

def copy_common_to_base_workflow(common_conf,  parent_workflow, current_base_workflow):
    for dir in os.listdir(current_base_workflow):
        if not os.path.exists(os.path.join(current_base_workflow, os.path.join(dir, ".base"))) \
                and os.listdir(os.path.join(current_base_workflow, dir)):
            copy_common_to_base_workflow(common_conf, os.path.join(parent_workflow, dir), os.path.join(current_base_workflow, dir))
        else:
            if os.path.exists(common_conf):
                os.system("cp -r " + common_conf + "/* " +   os.path.join(current_base_workflow, dir + "/"))
            start = os.path.join(current_base_workflow, dir)

            current_workflow = os.path.dirname(common_conf)
            with open(os.path.join(current_workflow, ".base"), 'r') as f:
                meta_workflow = os.path.join(current_workflow, f.readlines()[0].strip())
            if current_workflow == os.path.abspath(meta_workflow):
                end = common_conf
            else:
                end = os.path.join(parent_workflow, dir)
            update_base_file(start, end)

def update_base_file(start, end):
    relative_path = os.path.relpath(end, start)
    with open(os.path.join(start, ".base"), "w") as f:
        f.write(relative_path)
        f.close

def workflow_add_configuration(treeRoot, parent_workflow, current_workflow):
    if treeRoot.subFiles == []:
        return
    for subFile in treeRoot.subFiles:
        relpath = os.path.relpath(subFile.FilePath, parent_workflow)
        mkdirs(os.path.join(current_workflow, relpath))
        workflow_add_configuration(subFile, parent_workflow, current_workflow)

def get_workflow_tree(workflow):
    metadata = os.path.join(workflow, ".base")
    treeRoot = get_parent_workflow_tree(workflow)
    remove_list=[]
    add_list=[]
    with open(metadata, 'r') as f:
        for line in f:
            if "REMOVE" in line:
                remove_list = line.replace(" ", "").strip().split(":")[1].split(",")
            if "ADD" in line:
                add_list = line.replace(" ", "").strip().split(":")[1].split(",")
    return create_new_tree(treeRoot, remove_list, add_list)

def create_new_tree(treeRoot, remove_list, add_list):
    if remove_list != []:
        if "all" in remove_list:
            treeRoot_copy = FileROOT(treeRoot.FilePath, treeRoot.fileName, [])
            for list in add_list:
                create_tree_by_addList(treeRoot, treeRoot_copy, list.split("/"))
            treeRoot = treeRoot_copy
        else:
            for list in remove_list:
                create_tree_by_removeList(treeRoot, list.split("/"))
    else:
        if add_list != []:
            for list in add_list:
                create_tree_by_appendList(treeRoot,list.split("/"))
    return  treeRoot

def create_tree_by_removeList(treeRoot, list):
    if treeRoot.contains_subFile(list[0]):
        subfile = treeRoot.return_subFile(list[0])
        if len(list) == 2:
            if list[1].lower() == "all":
                treeRoot.remove_subFile(list[0])
            else:
                if subfile.contains_subFile(list[1]):
                    subfile.remove_subFile(list[1])
        else:
            list.remove(subfile.fileName)
            create_tree_by_removeList(subfile, list)
    return treeRoot

def create_tree_by_appendList(treeRoot ,list):
    if treeRoot.contains_subFile(list[0]):
        subfile = treeRoot.return_subFile(list[0])
        if len(list) == 2:
            if not subfile.contains_subFile(list[1]):
                subfile.add_subFile(FileROOT(os.path.join(subfile.FilePath, list[1]),  list[1], []))
            treeRoot.remove_subFile(list[0])
            treeRoot.add_subFile(subfile)
        else:
            subfile_copy = FileROOT(subfile.FilePath, subfile.fileName,subfile.subFiles)
            treeRoot.remove_subFile(list[0])
            treeRoot.add_subFile(subfile)
            list.remove(subfile.fileName)
            create_tree_by_addList(subfile, subfile_copy, list)
    else:
        tmp_root = treeRoot
        for dir in list:
            tmp_root.subFiles.append(FileROOT(os.path.join(tmp_root.FilePath, dir),  dir, []))
            tmp_root = tmp_root.return_subFile(dir)

def create_tree_by_addList(treeRoot, treeRoot_copy, list):
    if treeRoot.contains_subFile(list[0]):
        subfile = treeRoot.return_subFile(list[0])
        treeRoot_copy_subfile = treeRoot_copy.return_subFile(list[0]) if \
            treeRoot_copy.contains_subFile(list[0]) else FileROOT(subfile.FilePath, subfile.fileName, [])
        if len(list) == 2:
            if list[1].lower() == "all":
                treeRoot_copy_subfile.add_subFiles(subfile.subFiles)
            else:
                if subfile.contains_subFile(list[1]):
                    treeRoot_copy_subfile.add_subFile(subfile.return_subFile(list[1]))
                else:
                    treeRoot_copy_subfile.add_subFile(FileROOT(os.path.join(treeRoot_copy_subfile.FilePath, list[1]),  list[1], []))
            treeRoot_copy.remove_subFile(list[0])
            treeRoot_copy.add_subFile(treeRoot_copy_subfile)
        else:
            treeRoot_copy.remove_subFile(list[0])
            treeRoot_copy.add_subFile(treeRoot_copy_subfile)
            list.remove(subfile.fileName)
            create_tree_by_addList(subfile, treeRoot_copy_subfile, list)
    else:
        tmp_root = treeRoot_copy
        for dir in list:
            tmp_root.subFiles.append(FileROOT(os.path.join(tmp_root.FilePath, dir),  dir, []))
            tmp_root = tmp_root.return_subFile(dir)


def get_parent_workflow_tree(workflow):
    metadata = os.path.join(workflow, ".base")
    with open(metadata, 'r') as f:
         relpath = f.readlines()[0].strip()
    parent_workflow = os.path.abspath(os.path.join(workflow, relpath))
    if os.path.exists(os.path.join(parent_workflow, ".base")) and parent_workflow != workflow:
        parent_workflow = os.path.join(parent_workflow,  "output/output_workflow")
        parent_tree = FileROOT(parent_workflow, os.path.basename(parent_workflow), [])
    else:
        parent_tree = FileROOT(os.path.join(parent_workflow, "components"), "components",[])
    addTreeNode(parent_tree)
    return parent_tree

def addTreeNode(fileRooT):
    if not os.path.exists(os.path.join(fileRooT.FilePath, ".base")):
        for dir in os.listdir(fileRooT.FilePath):
            if os.path.isdir(os.path.join(fileRooT.FilePath, dir)) and dir != "oap-common":
                subFile = FileROOT(os.path.join(fileRooT.FilePath, dir), dir, [])
                fileRooT.subFiles.append(subFile)
                addTreeNode(subFile)

if __name__ == '__main__':
    args = sys.argv
    if len(args) < 1:
        exit(1)
    conf_path = os.path.abspath(args[len(args) - 1])
    if not os.path.exists(conf_path):
        print (colors.LIGHT_RED + "Please define .base file  under your repo: " + conf_path + colors.ENDC)
    update_workflow(conf_path)