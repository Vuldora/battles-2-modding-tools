import sys
import random
from PySide6 import QtCore, QtWidgets, QtGui
import subprocess
from jet import full_extract, full_pack
from pathlib import Path

class MainWindow(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()

        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(TabManager())

class TabManager(QtWidgets.QTabWidget):
    def __init__(self):
        super().__init__()

        self.addTab(ExtractTab(), "Extract")
        self.addTab(ArchiveTab(), "Archive")

class ExtractTab(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()

        self.button = QtWidgets.QPushButton("Extract Archive")
        self.button.setEnabled(False)
        self.button.clicked.connect(self.call_extract)
        self.source_selector = FileSelectorLine(
            "Source File:",
            QtGui.QIcon.fromTheme(QtGui.QIcon.ThemeIcon.DocumentOpen),
            0
        )
        self.destination_selector = FileSelectorLine(
            "Destination Folder:",
            QtGui.QIcon.fromTheme(QtGui.QIcon.ThemeIcon.FolderOpen),
            2
        )
        self.source_selector.line_edit.textChanged.connect(self.update_button)
        self.destination_selector.line_edit.textChanged.connect(self.update_button)

        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(self.source_selector)
        self.layout.addWidget(self.destination_selector)
        self.layout.addWidget(self.button)

    @QtCore.Slot()
    def call_extract(self):
        try:
            full_extract(
              self.source_selector.line_edit.text(),
              self.destination_selector.line_edit.text()
            )
            QtWidgets.QMessageBox.information(None, "Success", "Archive extracted successfully")
        except Exception as e:
            QtWidgets.QMessageBox.critical(None, "Error", f"An error occurred:\n{e}")

    def update_button(self): # Enable button if both line edits aren't empty
        self.button.setEnabled(
            self.source_selector.line_edit.text() != "" and
            self.destination_selector.line_edit.text() != ""
        )

class ArchiveTab(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()

        self.button = QtWidgets.QPushButton("Pack Archive")
        self.button.setEnabled(False)
        self.button.clicked.connect(self.call_pack)
        self.source_selector = FileSelectorLine(
            "Source Folder:",
            QtGui.QIcon.fromTheme(QtGui.QIcon.ThemeIcon.FolderOpen),
            2
        )
        self.destination_selector = FileSelectorLine(
            "Destination File:",
            QtGui.QIcon.fromTheme(QtGui.QIcon.ThemeIcon.DocumentOpen),
            1
        )
        self.source_selector.line_edit.textChanged.connect(self.update_button)
        self.destination_selector.line_edit.textChanged.connect(self.update_button)

        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(self.source_selector)
        self.layout.addWidget(self.destination_selector)
        self.layout.addWidget(self.button)

    @QtCore.Slot()
    def call_pack(self):
        try:
            full_pack(
                Path(self.source_selector.line_edit.text()),
                Path(self.destination_selector.line_edit.text())
            )
            QtWidgets.QMessageBox.information(None, "Success", "File saved successfully")
        except Exception as e:
            QtWidgets.QMessageBox.critical(None, "Error", f"An error occurred:\n{e}")

    def update_button(self): # Enable button if both line edits aren't empty
        self.button.setEnabled(
            self.source_selector.line_edit.text() != "" and
            self.destination_selector.line_edit.text() != ""
        )

class FileSelectorLine(QtWidgets.QWidget):
    def __init__(self, label_text : str, picker_icon : QtGui.QIcon, mode : int):
        super().__init__()

        self.line_edit = QtWidgets.QLineEdit()
        self.select_button =  QtWidgets.QPushButton(picker_icon, "")
        self.select_button.clicked.connect(lambda x: self.set_line_edit_text(self.line_edit, mode))

        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(QtWidgets.QLabel(label_text))
        self.row = QtWidgets.QHBoxLayout()
        self.layout.addLayout(self.row)
        self.row.addWidget(self.line_edit)
        self.row.addWidget(self.select_button)

    @QtCore.Slot()
    def set_line_edit_text(self, line_edit : QtWidgets.QLineEdit, mode : int):
        match mode:
            case 0:
                self.open_file_dialog(self.line_edit)
            case 1:
                self.save_file_dialog(self.line_edit)
            case 2:
                self.open_directory_dialog(self.line_edit)

    def open_file_dialog(self, line_edit : QtWidgets.QLineEdit):
        file_name = QtWidgets.QFileDialog.getOpenFileName(
            self,
            self.tr("Select File"),
            "",
            self.tr("JET files (*.jet);; All files (*)"
        ))
        line_edit.setText(file_name[0])

    def save_file_dialog(self, line_edit : QtWidgets.QLineEdit):
        dialog = QtWidgets.QFileDialog()
        dialog.defaultSuffix = ".jet"
        file_name = dialog.getSaveFileName(
            self,
            self.tr("Save Archive"),
            "",
            self.tr("JET files (*.jet);; All files (*)"
        ))
        line_edit.setText(file_name[0])

    def open_directory_dialog(self, line_edit):
        dir_name = QtWidgets.QFileDialog.getExistingDirectory(
            self,
            self.tr("Select Directory"),
            "",
            QtWidgets.QFileDialog.ShowDirsOnly | QtWidgets.QFileDialog.DontResolveSymlinks
        )
        line_edit.setText(dir_name)

if __name__ == "__main__":
    app = QtWidgets.QApplication([])

    widget = MainWindow()
    widget.resize(400, 240)
    widget.setWindowTitle("JET Archive Manager")
    widget.show()

    sys.exit(app.exec())
