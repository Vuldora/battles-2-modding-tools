import os
import sys
import hashlib

file_list = []

def get_files_recursive(path='.'):
    for entry in os.listdir(path):
        full_path = os.path.join(path, entry)
        if os.path.isdir(full_path):
            if full_path.endswith("asset_db"): continue
            get_files_recursive(full_path)
        else:
            file_list.append(full_path)

def get_file_hash(file_name):
    with open(file_name, 'rb') as file_to_check:
        data = file_to_check.read()
        return hashlib.md5(data).hexdigest()

if len(sys.argv) < 2:
    print("Command usage: python generate_manifest.py [folder_path]")
    sys.exit(1)
arg_dir = sys.argv[1]
if not arg_dir[-1] == "/":
    arg_dir += "/"
get_files_recursive(arg_dir + "game_data/")
file_list.sort()
with open(arg_dir + "manifest.txt", "w") as f:
    hashes = ""
    for i in range(len(file_list)):
        hashes += file_list[i][len(arg_dir):]
        hashes += ","
        hashes += get_file_hash(file_list[i])
        if i != len(file_list) - 1: hashes += "\n"
    f.write(hashes)
