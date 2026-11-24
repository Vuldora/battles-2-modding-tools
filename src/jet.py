import sys
import json
import tempfile
import shutil
from PIL import Image
from pathlib import Path
from extract_jet import extract_jet
from archive_jet import pack_jet
from bin_tool import process_path, process_file
from jpng2png import jpng_to_png, is_jpng
from png2jpng import png_to_jpng

JSON_EXT = {
    ".agent_blueprint",
    ".animation",
    ".animcontroller",
    ".animseq"
    ".b_school_opps",
    ".b_school_scenario_eco_target",
    ".b_school_scenario",
    ".chests",
    ".colours",
    ".gamerules",
    ".guild_symbols",
    ".hero_blueprint",
    ".hint_table",
    ".item_bundle",
    ".items"
    ".medals",
    ".scene",
    ".season",
    ".tower_blueprint",
    ".tower_info",
    ".track_list",
    ".track_metadata",
    ".trophyrules",
    ".ui_controller",
    ".ui_theme",
}

CSV_EXT = {
    ".roundset",
    ".bloonset",
    ".bloonset_loadouts",
    ".bloons"
}

JPNG_STRUCT = "<IIHBBI"

# Converts and cleans up the JET contents so they become more human-readable
def normalize(directory):
    for f in directory.rglob("*"):
        if not f.is_file(): continue

        if f.suffix in CSV_EXT: # For CSV files only add the extension and nothing else
            f.rename(f.with_name(f.name + ".csv"))

        elif f.suffix in JSON_EXT: # For JSON files also lint them on top of the rename
            f = f.rename(f.with_name(f.name + ".json"))

            try:
                with f.open("r", encoding="utf-8") as file:
                    data = json.load(file)

                with f.open("w", encoding="utf-8") as file:
                    json.dump(data, file, indent=4, ensure_ascii=False)
                    file.write("\n")

            except (json.JSONDecodeError, OSError) as e:
                  print(f"Failed to lint {f}: {e}")

        elif f.suffix == ".png": # Check if a jpng is larping as a png, if it is convert it to png
            with Image.open(f) as img:
                if img.format != "JPEG": continue

                if is_jpng(f):
                    f = f.rename(f.with_suffix(".jpng"))
                    jpng_to_png(f, f.with_suffix(".png"), True)
                    f.unlink()

                else:
                    f.rename(f.with_suffix(".jpg"))

# Opposite of the function above, reverses all QoL so that the game can read the JET content
def assemble(directory):
    extensions = CSV_EXT | JSON_EXT

    for f in directory.rglob("*"):
        if not f.is_file(): continue

        if f.suffix in [".json", ".csv"] and f.with_suffix("").suffix in extensions:
            f.rename(f.with_suffix(""))

        elif f.suffix == ".png":
            with Image.open(f) as img:
                if img.format == "PNG":
                    output_path = f.with_suffix(".jpng")
                    png_to_jpng(f, output_path, 100, True)
                    f.unlink()
                    output_path.rename(output_path.with_suffix(".png"))

        elif f.suffix == ".jpg":
            f.rename(f.with_suffix(".png"))

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

def full_extract(source, destination):
    destination_path = Path(destination)
    extract_jet(source, destination) # extract
    process_path(destination_path, None, "decrypt", False) # decrypt
    normalize(destination_path) # add csv/jsonfile extension and lint, convert jpng to png

def full_pack(source_path, destination_path):
    with tempfile.TemporaryDirectory() as temp_dir:
        working_dir = Path(temp_dir) / source_path.name
        shutil.copytree(source_path, working_dir)

        assemble(working_dir)
        encrypt_neccessary(working_dir)
        pack_jet(working_dir, destination_path)

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

        full_extract(source, destination)

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

        full_pack(source_path, destination_path)

