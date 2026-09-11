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

var view_operations := {
	0 : _on_button_overlay_pressed,
	1 : clear_overlay
}

enum EDIT_MODE{
	SELECT = 0,
	BRUSH = 1
}

var create_node_ui_funcs := {
	0 : Entity.get_creation_ui,
	1 : EntityMapArea.get_creation_ui,
	2 : EntityMapAreaNode.get_creation_ui,
	3 : EntityMapSideReference.get_creation_ui,
	4 : EntityTrack.get_creation_ui,
	5 : EntityTrackPathNode.get_creation_ui
}

var edit_mode : EDIT_MODE = EDIT_MODE.SELECT
var save_path : String
var global_id_count : int = 2
var current_track_node : int
var map_header : Header
var root_node : Entity
var previously_selected_visual : VisualNode
var previously_selected_item : TreeItem

var is_saving := false 
var is_creating := false

func _ready() -> void:
	new_file()
	
	$Control/Tree.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	$Control/Tree.set_column_expand(0, false)
	$Control/Tree.set_column_custom_minimum_width(0, 500)
	$Control/Tree.set_h_scroll_enabled(true)
	$Control/Tree.set_v_scroll_enabled(true)
	
	var file_popup : PopupMenu = $TopBar/Files.get_popup()
	file_popup.id_pressed.connect(_on_operation_selected.bind(file_operations))
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(0, KEY_MASK_CTRL | KEY_N)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(4, KEY_MASK_CTRL | KEY_S)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(5, KEY_MASK_CTRL |  KEY_MASK_SHIFT | KEY_S)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	file_popup.set_item_accelerator(10, KEY_MASK_CTRL | KEY_W)
	
	var view_popup : PopupMenu = $TopBar/View.get_popup()
	view_popup.id_pressed.connect(_on_operation_selected.bind(view_operations))

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

func _on_operation_selected(id : int, operations : Dictionary) -> void:
	var f : Callable = operations[id]
	f.call()

func new_file() -> void:
	save_path = ""
	is_saving = false
	is_creating = false
	update_buttons()
	$Control/Tree.clear()
	root_node = Entity.new(1, "Root", null, $Control/Tree)
	map_header = Header.new()
	map_header.version_code = 56
	map_header.id_gen_current_id = 160
	map_header.root = root_node

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
	update_buttons()
	if previously_selected_visual != null:
		previously_selected_visual.modulate = Color(1.0, 1.0, 1.0)
	var selected : TreeItem = $Control/Tree.get_selected()
	var node : Entity = selected.get_metadata(0)
	if node is EntityMapAreaNode or node is EntityTrackPathNode:
		node.visual.modulate = Color(0.7, 1.0, 0.7)
		previously_selected_visual = node.visual

func _on_tree_item_activated() -> void:
	var selected : TreeItem = $Control/Tree.get_selected()
	if previously_selected_item == selected:
		_on_button_edit_node_pressed()
	previously_selected_item = selected

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

func clear_overlay() -> void:
	$TextureRectOverlay.texture = null

func _on_button_add_node_pressed() -> void:
	is_creating = true
	$PanelChooseType.show()
	update_buttons()
	$Control/Tree.process_mode = Node.PROCESS_MODE_DISABLED
	$TopBar.process_mode = Node.PROCESS_MODE_DISABLED

func _on_button_del_node_pressed() -> void:
	var it : TreeItem = $Control/Tree.get_selected()
	var node : Entity = it.get_metadata(0)
	var parent_node : Entity = it.get_parent().get_metadata(0)
	if node is EntityMapAreaNode or node is EntityTrackPathNode:
		node.visual.queue_free()
		node.visual = null
	parent_node.entity_children.erase(node)
	if it: it.free()
	update_buttons()

func _on_button_edit_node_pressed() -> void:
	is_creating = true
	update_buttons()
	$Control/Tree.process_mode = Node.PROCESS_MODE_DISABLED
	$TopBar.process_mode = Node.PROCESS_MODE_DISABLED
	var it : TreeItem = $Control/Tree.get_selected()
	var node : Entity = it.get_metadata(0)
	add_child(node.get_edit_ui(done_with_creation))

func _on_button_exit_pressed() -> void:
	is_creating = false
	$PanelChooseType.visible = false
	update_buttons()
	$Control/Tree.process_mode = Node.PROCESS_MODE_INHERIT
	$TopBar.process_mode = Node.PROCESS_MODE_INHERIT

func _on_button_continue_node_pressed() -> void:
	$PanelChooseType.visible = false
	var create_func : Callable = create_node_ui_funcs[$PanelChooseType/OptionButton.selected]
	if $PanelChooseType/OptionButton.selected == 2:
		add_child(create_func.call($Control/Tree, global_id_count,
		done_with_creation, $VisualNodes, _on_visualnode_gui_input))
	else:
		add_child(create_func.call($Control/Tree, global_id_count, done_with_creation))

func done_with_creation(exit_code : int) -> void:
	if (exit_code == 0):
		global_id_count += 1
	is_creating = false
	update_buttons()
	$Control/Tree.process_mode = Node.PROCESS_MODE_INHERIT
	$TopBar.process_mode = Node.PROCESS_MODE_INHERIT

func update_buttons() -> void:
	var selected : TreeItem = $Control/Tree.get_selected()
	var node : Entity
	if selected != null:
		node = selected.get_metadata(0)
	$ButtonAddNode.disabled = selected == null or is_creating or is_saving
	$ButtonDelNode.disabled = $ButtonAddNode.disabled or selected == $Control/Tree.get_root()
	$ButtonEditNode.disabled = $ButtonDelNode.disabled
	$ToolBox/ToolBrush.disabled = $ButtonDelNode.disabled
	if not (node is EntityMapArea or node is EntityTrack):
		$ToolBox/ToolBrush.disabled = true
		_on_tool_pressed(0)

func _on_tool_pressed(mode: int) -> void:
	edit_mode = mode as EDIT_MODE
	for i in $ToolBox.get_child_count():
		var button : Button = $ToolBox.get_child(i)
		button.modulate = Color(0.7, 1.0, 0.7, 1.0) if mode == i else Color(1.0, 1.0, 1.0, 1.0)

func _on_color_rect_background_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("primary"):
		if edit_mode == EDIT_MODE.BRUSH:
			var selected : TreeItem = $Control/Tree.get_selected()
			var node : Entity = selected.get_metadata(0)
			if node is EntityMapArea:
				var visual := VisualNode.new()
				$VisualNodes.add_child(visual)
				visual.position = get_global_mouse_position()
				visual.connected_entity = EntityMapAreaNode.new(
					global_id_count,
					str("node_", global_id_count),
					node,
					$Control/Tree,
					canvas_pos_to_pos(get_global_mouse_position()),
					visual
				)
				visual.gui_input.connect(_on_visualnode_gui_input.bind(visual))
				global_id_count += 1
			if node is EntityTrack:
				var visual := VisualNode.new()
				$VisualNodes.add_child(visual)
				visual.position = get_global_mouse_position()
				visual.connected_entity = EntityTrackPathNode.new(
					global_id_count,
					str("node_", global_id_count),
					node,
					$Control/Tree,
					2,
					global_id_count - 1,
					canvas_pos_to_pos(get_global_mouse_position()),
					visual
				)
				visual.gui_input.connect(_on_visualnode_gui_input.bind(visual))
				global_id_count += 1

func _on_visualnode_gui_input(input : InputEvent, visual : VisualNode) -> void:
	if input.is_action_pressed("primary") and edit_mode == EDIT_MODE.SELECT:
		if previously_selected_visual != null:
			previously_selected_visual.modulate = Color(1.0, 1.0, 1.0)
		visual.modulate = Color(0.7, 1.0, 0.7)
		previously_selected_visual = visual
		$Control/Tree.set_selected(visual.connected_entity.tree_item, 0)
		$Control/Tree.grab_click_focus()
		previously_selected_item = visual.connected_entity.tree_item

func canvas_pos_to_pos(pos : Vector2) -> Vector3:
	return Vector3((pos.x - 680.0) * 0.44, 0.0, (pos.y - 460.0) * 0.44)

func quit() -> void:
	get_tree().quit()
