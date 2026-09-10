class_name EntityMapSideReference extends Entity

var map_side_reference : MapSideReference
var entity_rotation : Vector3

func _init(id : int = 0, name : String = "", parent : Entity = null, tree : Tree = null,
map_side_reference_ : MapSideReference = null, entity_rotation_ : Vector3 = Vector3.ZERO) -> void:
	super._init(id, name, parent, tree)
	map_side_reference = map_side_reference_
	entity_rotation = entity_rotation_

func get_type_string() -> String:
	return "MapSideReference"

func to_dict() -> Dictionary:
	var data := super.to_dict()
	data.set("map_side_reference", map_side_reference.to_dict())
	data.set("entity_rotation", [entity_rotation.x, entity_rotation.y, entity_rotation.z])
	return data

func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	map_side_reference.from_dict(data.get("map_side_reference", {}))
	var rotation_arr : Array[float] = data.get("entity_rotation", [0.0, 0.0, 0.0])
	entity_rotation = Vector3(rotation_arr[0], rotation_arr[1], rotation_arr[2])

static func get_creation_ui(tree : Tree, global_id : int, done_func : Callable) -> Control:
	var root := super.get_creation_ui(tree, global_id, done_func)
	root.size = Vector2(300.0, 320.0)
	root.position = (viewport_size - root.size) * 0.5
	var line_edit : LineEdit = root.get_node("line_edit")
	var create_button : Button = root.get_node("create_button")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	var title : Label = root.get_node("title")
	title.text = "Create MapSideRefrence Node"
	
	var seperator1 := HSeparator.new()
	root.add_child(seperator1)
	seperator1.size = Vector2(260.0, 16.0)
	seperator1.position = Vector2(20.0, 80.0)
	
	var label_rotation := Label.new()
	root.add_child(label_rotation)
	label_rotation.text = "Rotation"
	label_rotation.position = Vector2(16.0, 92.0)
	
	var slider_x = DegreeSlider.new("X")
	slider_x.position = Vector2(16.0, 116.0)
	root.add_child(slider_x)
	
	var slider_y = DegreeSlider.new("Y")
	slider_y.position = Vector2(16.0, 140.0)
	root.add_child(slider_y)
	
	var slider_z = DegreeSlider.new("Z")
	slider_z.position = Vector2(16.0, 164.0)
	root.add_child(slider_z)
	
	var seperator2 := HSeparator.new()
	root.add_child(seperator2)
	seperator2.size = Vector2(260.0, 16.0)
	seperator2.position = Vector2(20.0, 184.0)
	
	var label_side := Label.new()
	root.add_child(label_side)
	label_side.text = "Side"
	label_side.position = Vector2(16.0, 200.0)
	
	var spin_box_side := SpinBox.new()
	root.add_child(spin_box_side)
	spin_box_side.value = 1
	spin_box_side.position = Vector2(196.0, 200.0)
	
	var label_mode := Label.new()
	root.add_child(label_mode)
	label_mode.text = "Mode"
	label_mode.position = Vector2(16.0, 236.0)
	
	var spin_box_mode := SpinBox.new()
	root.add_child(spin_box_mode)
	spin_box_mode.value = 1
	spin_box_mode.position = Vector2(196.0, 236.0)
	
	create_button.position.y = 280.0
	create_button.pressed.connect(
		func():
			var map_side_reference_ = MapSideReference.new(int(spin_box_side.value), int(spin_box_mode.value))
			EntityMapSideReference.new(global_id, line_edit.text, tree.get_selected().get_metadata(0), tree,
			map_side_reference_, Vector3(slider_x.get_rad(), slider_y.get_rad(), slider_z.get_rad()))
			done_func.call(0)
			root.queue_free()
	)
	
	return root
