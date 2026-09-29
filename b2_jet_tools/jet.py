import sys
import json
import tempfile
import shutil
from pathlib import Path
from extract_jet import extract_jet
from archive_jet import pack_jet
from bin_tool import process_path, process_file

JSON_EXT = {
    ".scene",
    ".tower_blueprint",
    ".hero_blueprint",
    ".agent_blueprint",
    ".track_list",
    ".track_metadata",
    ".gamerules"
}

CSV_EXT = {
    ".roundset",
    ".bloonset",
    ".bloonset_loadouts",
    ".bloons"
}

# Recursively turn the appropriate files in a directory into linted json
def jsonify(directory):
    json_files = [
        file
        for file in directory.rglob("*")
        if file.is_file() and file.suffix in JSON_EXT
    ]

    for file in json_files:
        #print(f"Linting {file}...") # Uncomment this line to see what is failing at this stage
        with file.open("r", encoding="utf-8") as f:
            data = json.load(f)

        new_file = file.with_name(file.name + ".json")
        file.rename(new_file)

        with new_file.open("w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
            f.write("\n")

# Same as above but for CSV
def csvify(directory):
    csv_file = [
        file
        for file in directory.rglob("*")
        if file.is_file() and file.suffix in CSV_EXT
    ]

    for file in csv_file:
        new_file = file.with_name(file.name + ".csv")
        file.rename(new_file)

# Removes extensions recursively
def remove_extension(directory, extension, ext_list):
    files = [
        file
        for file in directory.rglob("*")
        if file.is_file() and file.suffix in extension
    ]

    for file in files:
        if file.with_suffix("").suffix in ext_list:
            file.rename(file.with_suffix(""))

# Encrypts files that should be encrypted
def encrypt_neccessary(directory):
    files = [
        file
        for file in directory.rglob("*")
        if file.is_file() and file.suffix in (CSV_EXT | JSON_EXT | { ".csv", ".txt" })
    ]

    for file in files:
        process_file(file, file, "encrypt", False)
        print(f"{file} is being encrypted")

if __name__ == "__main__":

    if len(sys.argv) <= 1 or len(sys.argv) >= 4:
        print(
            "Invalid syntax\n"
            "Extract: jet <input.jet> [optional_output_directory]\n"
            "Pack:    jet <directory> [optional_output_file.jet]"
        )
        sys.exit(1)

    source = sys.argv[1]
    source_path = Path(source)

    if not source_path.exists():
            print(f"The path {source} does not exist")
            sys.exit(1)

    destination = ""

    if len(sys.argv) == 3:
        destination = sys.argv[2]

    # Extraction
    if source[-4:] == ".jet":
        if source_path.is_dir():
            print(f"Expected .jet file but {source} is a directory")
            sys.exit(1)

        if not destination:
            destination = source[:-4]

        elif destination[-4:] == ".jet":
            print(
                "Invalid syntax\n"
                "Extract: jet <input.jet> [optional_output_directory]\n"
                "Pack:    jet <directory> [optional_output_file.jet]"
            )
            sys.exit(1)

        destination_path = Path(destination)

        extract_jet(source, destination) # extract
        process_path(destination_path, None, "decrypt", False) # decrypt
        jsonify(destination_path) # rename to json and lint
        csvify(destination_path) # rename to csv

    # Pack
    else:
        if source_path.is_file():
            print(
                f"{source} is not a .jet file or a folder"
            )
            sys.exit(1)

        if not destination:
            destination_path = source_path.parent / (source_path.name + ".jet")
        else:
          destination_path = Path(destination)

        with tempfile.TemporaryDirectory() as temp_dir:
            working_dir = Path(temp_dir) / source_path.name
            shutil.copytree(source_path, working_dir)

            remove_extension(working_dir, ".json", JSON_EXT)
            remove_extension(working_dir, ".csv", CSV_EXT)
            encrypt_neccessary(working_dir)
            pack_jet(working_dir, destination_path)

