import os
import hashlib
import shutil
import sys
import random
import asyncio
import platform
from pathlib import Path
from PySide6 import QtCore, QtWidgets, QtGui

current_os = platform.system()

class MainWindow(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Battles 2 Mod Loader (B2-MLQT)")

        # Default paths
        if current_os == "Windows":
            self.game_data_path = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Bloons TD Battles 2\\game_data\\game_project\\asset_bundles"
        elif current_os == "Linux":
            self.game_data_path = f"{Path.home()}/.local/share/Steam/steamapps/common/Bloons TD Battles 2/game_data/game_project/asset_bundles"
        else:
            self.game_data_path = ""
            QtWidgets.QMessageBox.warning(
                self, "Incompatible Operating System",
                f"Detected operating system: {current_os}\nThis mod loader only supports Linux and Windows\nYou are at risk of deleting curicial system files if unexpected behavior occurs, use at your on risk")
        self.downloads_data_path = ""
        self.downloads_folder = ""

        # Game data path section
        self.path_widget = QtWidgets.QWidget()
        self.path_widget_box = QtWidgets.QHBoxLayout(self.path_widget)
        self.path_widget.setLayout(self.path_widget_box)

        self.path_text = QtWidgets.QLabel("Game data path")
        self.path_lineedit = QtWidgets.QLineEdit()
        self.path_lineedit.setText(self.game_data_path)
        self.path_lineedit.setPlaceholderText(".../steamapps/common/Bloons TD Battles 2/game_data/game_project/asset_bundles")
        self.open_path_button = QtWidgets.QPushButton()
        self.open_path_button.setIcon(
            self.style().standardIcon(QtWidgets.QStyle.SP_DirOpenIcon))

        # Downloads folder location section
        self.downloads_text = QtWidgets.QLabel("Steam user to modify for OTA downloads")
        self.account_buttons = QtWidgets.QButtonGroup()

        # Create a radio button for every Steam user
        userdata_root = Path(f"{Path.home()}/.local/share/Steam/userdata")
        if current_os == "Windows":
            userdata_root = Path("C:/Program Files (x86)/Steam/userdata")
        for item in userdata_root.iterdir():
            if item.is_file(): continue
            radio_button = QtWidgets.QRadioButton(text=item.name)
            radio_button.setProperty("user_id", item.name)
            radio_button.clicked.connect(self.change_ota_user)
            self.account_buttons.addButton(radio_button)

        # Create backup section
        self.back_make_text = QtWidgets.QLabel(
            "Create a backup when the game is still unmodified\nafter that never press the create a backup button unless the game updates")
        self.back_make_button = QtWidgets.QPushButton("Create Backup")
        self.back_make_status = QtWidgets.QLabel("Done!")
        self.back_make_status.hide()

        # Load backup section
        self.back_load_text = QtWidgets.QLabel(
            "Click load backup to restore the game to vanilla, if you loaded\nOTA mods then you will have to clear downloads and restart the game")
        self.back_load_button = QtWidgets.QPushButton("Load Backup")
        if not Path("./original_files").is_dir():
            self.back_load_button.setDisabled(True)
        self.back_load_status = QtWidgets.QLabel("Done!")
        self.back_load_status.hide()

        # Delete downloads section
        self.clear_downloads_button = QtWidgets.QPushButton("Clear Downloads")
        self.clear_downloads_button.setDisabled(True)
        self.clear_downloads_status = QtWidgets.QLabel("Done!")
        self.clear_downloads_status.hide()

        # Mod loading section
        self.mods_desc = QtWidgets.QLabel(
          "Launch Battles 2 and click load mods while in the main menu\nIf you accidentally do that before the game is open then load the backup")

        # game_data mods
        self.mods_widget = QtWidgets.QWidget()
        self.mods_widget_box = QtWidgets.QHBoxLayout(self.mods_widget)
        self.mods_widget.setLayout(self.mods_widget_box)
        self.mods_label = QtWidgets.QLabel("JETs to load")
        self.add_mod_button = QtWidgets.QPushButton()
        self.add_mod_button.setIcon(
            self.style().standardIcon(QtWidgets.QStyle.SP_DialogOpenButton))
        self.del_mod_button = QtWidgets.QPushButton()
        self.del_mod_button.setIcon(
            self.style().standardIcon(QtWidgets.QStyle.SP_DialogCancelButton))
        self.mods_list = QtWidgets.QListWidget()

        # downloads folder mods
        self.otas_widget = QtWidgets.QWidget()
        self.otas_widget_box = QtWidgets.QHBoxLayout(self.otas_widget)
        self.otas_widget.setLayout(self.otas_widget_box)
        self.otas_label = QtWidgets.QLabel("OTAs to load")
        self.add_ota_button = QtWidgets.QPushButton()
        self.add_ota_button.setIcon(
            self.style().standardIcon(QtWidgets.QStyle.SP_DialogOpenButton))
        self.del_ota_button = QtWidgets.QPushButton()
        self.del_ota_button.setIcon(
            self.style().standardIcon(QtWidgets.QStyle.SP_DialogCancelButton))
        self.otas_list = QtWidgets.QListWidget()

        # Load mods section
        self.load_mods_button = QtWidgets.QPushButton("Load Mods")
        self.load_mods_button.setDisabled(True)
        self.mod_load_status = QtWidgets.QLabel("Mods loaded!")
        self.mod_load_status.hide()

        # Add everything to the layout
        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(self.path_text)
        self.layout.addWidget(self.path_widget)
        self.path_widget_box.addWidget(self.path_lineedit)
        self.path_widget_box.addWidget(self.open_path_button)
        self.layout.addWidget(self.back_make_text)
        self.layout.addWidget(self.back_make_button)
        self.layout.addWidget(self.back_make_status)
        self.layout.addWidget(self.back_load_text)
        self.layout.addWidget(self.back_load_button)
        self.layout.addWidget(self.back_load_status)
        self.layout.addWidget(self.clear_downloads_button)
        self.layout.addWidget(self.clear_downloads_status)
        self.layout.addWidget(self.downloads_text)
        for b in self.account_buttons.buttons(): self.layout.addWidget(b)
        self.layout.addWidget(self.mods_desc)
        self.layout.addWidget(self.mods_widget)
        self.mods_widget_box.addWidget(self.mods_label)
        self.mods_widget_box.addWidget(self.add_mod_button)
        self.mods_widget_box.addWidget(self.del_mod_button)
        self.layout.addWidget(self.mods_list)
        self.layout.addWidget(self.otas_widget)
        self.otas_widget_box.addWidget(self.otas_label)
        self.otas_widget_box.addWidget(self.add_ota_button)
        self.otas_widget_box.addWidget(self.del_ota_button)
        self.layout.addWidget(self.otas_list)
        self.layout.addWidget(self.load_mods_button)
        self.layout.addWidget(self.mod_load_status)

        # Signals
        self.back_make_button.clicked.connect(self.backup_jets)
        self.back_load_button.clicked.connect(self.load_backup)
        self.clear_downloads_button.clicked.connect(self.clear_downloads)
        self.open_path_button.clicked.connect(self.select_game_data_path)
        self.add_mod_button.clicked.connect(
            lambda: self.add_to_list(self.mods_list, "Choose mod file(s)")
          )
        self.del_mod_button.clicked.connect(
            lambda: self.del_from_list(self.mods_list)
          )
        self.add_ota_button.clicked.connect(
            lambda: self.add_to_list(self.otas_list, "Choose OTA file(s)")
          )
        self.del_ota_button.clicked.connect(
            lambda: self.del_from_list(self.otas_list)
          )
        self.load_mods_button.clicked.connect(self.load_mods)

    @QtCore.Slot()
    def backup_jets(self):
        assert self.game_data_path != ""
        assert self.game_data_path != "/"
        self.back_make_status.show()
        folder_path = Path("original_files")
        folder_path.mkdir(parents=True, exist_ok=True)
        shutil.copytree(
            Path(self.game_data_path),
            Path("original_files"),
            dirs_exist_ok=True,
            copy_function=copy_if_different
        )
        self.back_load_button.setDisabled(False)
        QtCore.QTimer.singleShot(3000, self.back_make_status.hide)

    def load_backup(self):
        assert self.game_data_path != ""
        assert self.game_data_path != "/"
        self.back_load_status.show()
        shutil.copytree(
            Path("original_files"),
            Path(self.game_data_path),
            dirs_exist_ok=True,
            copy_function=copy_if_different
        )
        QtCore.QTimer.singleShot(3000, self.back_load_status.hide)

    def select_game_data_path(self):
        path = QtWidgets.QFileDialog.getExistingDirectory(
            self,
            "Select Game Data Directory",
            self.game_data_path
        )

        if path:
            self.game_data_path = path
            self.path_lineedit.setText(path)

    def change_ota_user(self):
        if (self.mods_list.count() > 0 or self.otas_list.count() > 0):
            self.load_mods_button.setDisabled(False)
        self.clear_downloads_button.setDisabled(False)
        user_id = self.account_buttons.checkedButton().property("user_id")
        if current_os == "Linux":
            self.downloads_data_path = f"{Path.home()}/.local/share/Steam/userdata/{user_id}/1276390/local/Data/Downloads/com.ninjakiwi.link/a7365dca90635a8ec87bd70d8c3668fc"
            self.downloads_folder = f"{Path.home()}/.local/share/Steam/userdata/{user_id}/1276390/local/Data/Downloads"
        if current_os == "Windows":
            self.downloads_data_path = f"C:\\Program Files (x86)\\Steam\\userdata\\{user_id}\\1276390\\local\\Data\\Downloads\\com.ninjakiwi.link\\a7365dca90635a8ec87bd70d8c3668fc"
            self.downloads_folder = f"C:\\Program Files (x86)\\Steam\\userdata\\{user_id}\\1276390\\local\\Data\\Downloads"

    def add_to_list(self, list_widget, title):
        files, _ = QtWidgets.QFileDialog.getOpenFileNames(
            self,
            title,
            "",
            "JET files (*.jet);;All Files (*)"
        )
        for f in files:
            if not list_widget.findItems(f, QtCore.Qt.MatchFlag.MatchExactly):
                list_widget.addItem(f)
        if (self.mods_list.count() > 0 or self.otas_list.count() > 0) and (self.account_buttons.checkedButton() != None):
            self.load_mods_button.setDisabled(False)

    def del_from_list(self, list_widget):
        list_widget.takeItem(list_widget.currentRow())
        if (self.mods_list.count() == 0 and self.otas_list.count() == 0):
            self.load_mods_button.setDisabled(True)

    def load_mods(self):
        mods_to_load = [
            self.mods_list.item(i).text()
            for i in range(self.mods_list.count())
        ]
        otas_to_load = [
            self.otas_list.item(i).text()
            for i in range(self.otas_list.count())
        ]
        assert self.game_data_path != ""
        assert self.game_data_path != "/"
        for f in mods_to_load:
            shutil.copy(f, Path(self.game_data_path))
        assert self.downloads_data_path != ""
        assert self.downloads_data_path != "/"
        for f in otas_to_load:
            shutil.copy(f, Path(self.downloads_data_path))
        self.mod_load_status.show()
        QtCore.QTimer.singleShot(5000, self.mod_load_status.hide)

    def clear_downloads(self):
        assert self.downloads_folder != ""
        assert self.downloads_folder != "/"
        dl_path = Path(self.downloads_folder)
        if dl_path.exists() and dl_path.is_dir():
            shutil.rmtree(dl_path)
        self.clear_downloads_status.show()
        QtCore.QTimer.singleShot(3000, self.clear_downloads_status.hide)


def file_hash(path, chunk_size=1024 * 1024):
    h = hashlib.sha256()

    with open(path, "rb") as f:
        while chunk := f.read(chunk_size):
            h.update(chunk)

    return h.digest()


def copy_if_different(src, dst):
    if os.path.exists(dst):
        if os.path.getsize(src) == os.path.getsize(dst):
            if file_hash(src) == file_hash(dst):
                return dst

    return shutil.copy2(src, dst)

if __name__ == "__main__":
    app = QtWidgets.QApplication([])

    widget = MainWindow()
    widget.show()

    sys.exit(app.exec())
