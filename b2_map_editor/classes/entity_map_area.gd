class_name EntityMapArea extends Entity

var map_area : MapArea

func _init(id : int = 0, name : String = "", parent : Entity = null, tree : Tree = null,
map_area_ : MapArea = null) -> void:
	super._init(id, name, parent, tree)
	map_area = map_area_

func get_type_string() -> String:
	return "MapArea"

func to_dict() -> Dictionary:
	var data := super.to_dict()
	data.set("map_area", map_area.to_dict())
	return data

func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	var map_area_dict = data.get("map_area", {})
	map_area = MapArea.new()
	map_area.from_dict(map_area_dict)

static func get_creation_ui(tree : Tree, global_id : int, done_func : Callable) -> Control:
	var root := super.get_creation_ui(tree, global_id, done_func)
	root.size = Vector2(300.0, 480.0)
	root.position = (viewport_size - root.size) * 0.5
	var line_edit : LineEdit = root.get_node("line_edit")
	var create_button : Button = root.get_node("create_button")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	var title : Label = root.get_node("title")
	title.text = "Create MapArea Node"
	var exit_button : Button = root.get_node("exit_button")
	exit_button.position.x = 260.0
	
	var seperator1 := HSeparator.new()
	root.add_child(seperator1)
	seperator1.size = Vector2(268.0, 24.0)
	seperator1.position = Vector2(16.0, 76.0)
	
	var label_side := Label.new()
	root.add_child(label_side)
	label_side.text = "Side"
	label_side.position = Vector2(16.0, 96.0)
	
	var line_edit_side := LineEdit.new()
	root.add_child(line_edit_side)
	line_edit_side.position = Vector2(156.0, 96.0)
	line_edit_side.size.x = 128.0
	
	var label_type := Label.new()
	root.add_child(label_type)
	label_type.text = "Type"
	label_type.position = Vector2(16.0, 136.0)
	
	var line_edit_type := LineEdit.new()
	root.add_child(line_edit_type)
	line_edit_type.position = Vector2(156.0, 136.0)
	line_edit_type.size.x = 128.0
	
	var label_source := Label.new()
	root.add_child(label_source)
	label_source.text = "Source Entity ID"
	label_source.position = Vector2(16.0, 176.0)
	
	var spinbox_souce := SpinBox.new()
	root.add_child(spinbox_souce)
	spinbox_souce.position = Vector2(172.0, 176.0)
	
	var label_layer := Label.new()
	root.add_child(label_layer)
	label_layer.text = "Layer"
	label_layer.position = Vector2(16.0, 216.0)
	
	var spinbox_layer := SpinBox.new()
	root.add_child(spinbox_layer)
	spinbox_layer.position = Vector2(172.0, 216.0)
	
	var slider_elevation := GenericSlider.new("Elevation Offset", 0.0, 0.0, 10.0, 6)
	root.add_child(slider_elevation)
	slider_elevation.position = Vector2(16.0, 256.0)
	slider_elevation.slider.position.x += 96.0
	slider_elevation.slider.size.x -= 96.0
	
	var slider_hit := GenericSlider.new("Hit Area Offset", 0.0, 0.0, 10.0, 6)
	root.add_child(slider_hit)
	slider_hit.position = Vector2(16.0, 296.0)
	slider_hit.slider.position.x += 96.0
	slider_hit.slider.size.x -= 96.0
	
	var label_removable := Label.new()
	root.add_child(label_removable)
	label_removable.text = "Removable"
	label_removable.position = Vector2(16.0, 336.0)
	
	var check_removable := CheckButton.new()
	root.add_child(check_removable)
	check_removable.position = Vector2(192.0, 336.0)
	
	var label_teleporter := Label.new()
	root.add_child(label_teleporter)
	label_teleporter.text = "Teleporter"
	label_teleporter.position = Vector2(16.0, 368.0)
	
	var check_teleporter := CheckButton.new()
	root.add_child(check_teleporter)
	check_teleporter.position = Vector2(192.0, 368.0)
	
	var label_bone := Label.new()
	root.add_child(label_bone)
	label_bone.text = "Attached to Bone"
	label_bone.position = Vector2(16.0, 400.0)
	
	var check_bone := CheckButton.new()
	root.add_child(check_bone)
	check_bone.position = Vector2(192.0, 400.0)
	
	create_button.position = Vector2(120.0, 440.0)
	create_button.pressed.connect(
		func():
			var map_area_ = MapArea.new(
				line_edit_side.text,
				line_edit_type.text,
				int(spinbox_souce.value),
				int(spinbox_layer.value),
				slider_elevation.get_value(),
				slider_hit.get_value(),
				check_removable.button_pressed,
				check_teleporter.button_pressed,
				check_bone.button_pressed
			)
			EntityMapArea.new(global_id, line_edit.text, tree.get_selected().get_metadata(0), tree,
			map_area_)
			done_func.call(0)
			root.queue_free()
	)
	
	return root
