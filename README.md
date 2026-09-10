# Modding
Battles 2 stores the assets it uses in archive files called JET files, these files behave similarly to password protected ZIP files.
JETs are stored in two locations:
1. Game Data: `STEAM_HOME/steamapps/common/Bloons TD Battles 2/game_data/game_project/asset_bundles`
2. Over-The-Air Downloads: `STEAM_HOME/userdata/USER_ID/1276390/local/Data/Downloads/com.ninjakiwi.link/a7365dca90635a8ec87bd70d8c3668fc`
There are minor differences between the JETs in each folder:
- OTA JETs will typically include only balance patches and other minor files, while game data JETs will include everything the game uses.
- The latest OTA JETs will overwrite the equivalent game data jet.
- When modified OTA JETs get automatically re-downloaded on game launch whereas game data do not.
On the loading screen the game runs a check to see if all JET files are valid, and if it detects mismatch it will prevent you from proceeding. However we can easily bypass this security measure by overwriting the JET files while already loaded and on the main menu.
Overall the workload for modding the game is as follows:
Extract original JETs -> Make desired modifications -> Archive new JET -> Overwrite the original JET file while the game is running
# Tools
When modding files manually you will quickly run into a bunch of issues such as encrypted files, proprietary formats, lengthy computer generated files, etc...
This repository consists of programs that takes care of that and makes the modding process much simpler.
# Prerequisites
Before using any of the tools you must have the following dependencies:
- Linux or Windows system (Unix-like operating systems may work, mobile devices are unsupported).
- Python: installed through the official website <https://www.python.org/downloads/> or using your distro's package manager.
- PySide6: installed using pip `pip install pyside6`, or using your distro's package manager.
# Extract JET Tool
Extracts files from a JET archive.
Usage: `python extract_jet.py [JET_NAME] [DESTINATION]`
Example: `python extract_jet.py map_mayan_12345abcd.jet my_folder`
# Archive JET Tool
Archives the contents of a folder into a new JET file.
`python archive_jet.py [SOURCE] [OUTPUT]`
Example: `python archive_jet.py  my_quincy_mod_folder hero_quincy_low_med_lrg_12345abcd.jet`
# Bin Tool
On top of password protecting the JET archives, some files have a second layer of encryption. Most notably scene files, asset tables, and most text-based files, all start with the string BIN2.0 followed by scrambled data. This tool allows decrypting and encrypting this type of file.
However do note that the game will crash if it gets a decrypted file when it expect an encrypted file and vice versa.
Usage: `python bin_tool.py [OPERATION] [INPUT]`
Operation is either `-d` for decrypt, or `-e` for encrypt.
Optional: `python bin_tool.py [OPERATION] [INPUT] -o [OUTPUT]`
Including the `-o` flag will create a new file instead of modifying the input file.
Examples:
Decrypt a file called file.scene
`python bin_tool.py -d file.scene`
Encrypt a file called asset_table.csv
`python bin_tool.py -e assets_table.csv`
Decrypt an entire folder
`python bin_tool.py -d my_folder`
Encrypt file without modifying the original
`python bin_tool.py -e file1 -o file2`
# MLQT
Graphical mod loader tool for convenience, instructions are included in the program.
You can replicate everything it does by copy pasting modified JETs manually into the aforementioned game data and OTA folders if you prefer.
# File Formats
**JPNG (unencrypted):** Despite having the .png file extension, all textures the game uses are actually JPNG files which is a custom image format.
You can use the Monkey Wrench tool to convert images from/to JPNG (custom tool WIP).
**NKMesh (unencrypted):** Proprietary 3D model format that is currently WIP.
**JSON (encrypted):** Scene files and other data files are JSON without the file extension, use a text/code editor.
**CSV (encrypted):** Asset tables, bloon sends, and other data are CSV without the file extension, use a text/code editor.
**Text (encrypted):** Plain text, no need for special tools.
**Sound (unencrypted):** Uses common formats, no need for special tools.
