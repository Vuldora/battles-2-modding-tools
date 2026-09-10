extends Control

var file_operations := {
	0 : new_file,
	1 : "open",
	2 : "open recent",
	3 : quick_save,
	4 : save_as,
	5 : "undo",
	6 : "redo",
	7 : quit
}

var create_node_ui_funcs := {
	0 : Entity.get_creation_ui,
	1 : EntityMapArea.get_creation_ui,
	2 : EntityMapSideReference.get_creation_ui,
	3 : EntityTrack.get_creation_ui
}

var save_path : String
var global_id_count : int = 2
var map_header : Header
var root_node : Entity

var is_saving := false 
var is_creating := false

func _ready() -> void:
	new_file()
	
	var file_popup : PopupMenu = $TopBar/Files.get_popup()
	file_popup.id_pressed.connect(_on_file_operation_selected)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(0, KEY_MASK_CTRL | KEY_N)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(4, KEY_MASK_CTRL | KEY_S)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(5, KEY_MASK_CTRL |  KEY_MASK_SHIFT | KEY_S)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(10, KEY_MASK_CTRL | KEY_W)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("new_file"):
		if not is_creating and not is_saving: 
			new_file()
	if Input.is_action_just_pressed("save"):
		if not is_creating:
			quick_save()
	if Input.is_action_just_pressed("save_as"):
		if not is_creating:
			save_as()
	if Input.is_action_just_pressed("quit"):
		quit()

func _on_file_operation_selected(id : int) -> void:
	var f : Callable = file_operations[id]
	f.call()

func quick_save() -> void:
	if save_path.is_empty():
		save_as()
		return
	var data := map_header.to_dict()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to save")
		return
	file.store_string(JSON.stringify(data, "  "))
	file.close()

func save_as() -> void:
	if is_saving: return
	is_saving = true
	var file_dialog := FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.file_selected.connect(
		func(path):
			save_path = path
			quick_save()
			is_saving = false
			file_dialog.queue_free()
	)
	file_dialog.canceled.connect(
		func():
			is_saving = false
	)
	file_dialog.popup_centered_clamped.call_deferred()

func _on_tree_item_selected() -> void:
	$ButtonAddNode.disabled = false
	$ButtonDelNode.disabled = $Tree.get_selected() == $Tree.get_root()

func _on_button_overlay_pressed() -> void:
	var file_dialog := FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.file_selected.connect(load_overlay.bind(file_dialog))
	file_dialog.popup_centered_clamped.call_deferred()

func load_overlay(path : String, source : FileDialog) -> void:
	var image := Image.load_from_file(path)
	var overlay_texture := ImageTexture.create_from_image(image)
	$TextureRectOverlay.texture = overlay_texture
	source.queue_free()

func _on_button_add_node_pressed() -> void:
	is_creating = true
	$PanelChooseType.visible = true
	$ButtonAddNode.disabled = true
	$ButtonDelNode.disabled = true
	$Tree.process_mode = Node.PROCESS_MODE_DISABLED
	$TopBar.process_mode = Node.PROCESS_MODE_DISABLED

func _on_button_del_node_pressed() -> void:
	var it : TreeItem = $Tree.get_selected()
	var node : Entity = it.get_metadata(0)
	var parent_node : Entity = it.get_parent().get_metadata(0)
	parent_node.entity_children.erase(node)
	if it: it.free()
	$ButtonAddNode.disabled = true
	$ButtonDelNode.disabled = true

func _on_button_exit_pressed() -> void:
	is_creating = false
	$PanelChooseType.visible = false
	$ButtonAddNode.disabled = false
	$ButtonDelNode.disabled = $Tree.get_selected() == $Tree.get_root()
	$Tree.process_mode = Node.PROCESS_MODE_INHERIT
	$TopBar.process_mode = Node.PROCESS_MODE_INHERIT

func _on_button_continue_node_pressed() -> void:
	$PanelChooseType.visible = false
	var create_func : Callable = create_node_ui_funcs[$PanelChooseType/OptionButton.selected]
	add_child(create_func.call($Tree, global_id_count, done_with_creation))

func done_with_creation(exit_code : int) -> void:
	if (exit_code == 0):
		global_id_count += 1
	is_creating = false
	$ButtonAddNode.disabled = false
	$ButtonDelNode.disabled = $Tree.get_selected() == $Tree.get_root()
	$Tree.process_mode = Node.PROCESS_MODE_INHERIT
	$TopBar.process_mode = Node.PROCESS_MODE_INHERIT

func new_file() -> void:
	$ButtonAddNode.disabled = true
	$ButtonDelNode.disabled = true
	save_path = ""
	is_saving = false
	$Tree.clear()
	root_node = Entity.new(1, "Root", null, $Tree)
	map_header = Header.new()
	map_header.version_code = 56
	map_header.id_gen_current_id = 160
	map_header.root = root_node

func quit() -> void:
	get_tree().quit()
