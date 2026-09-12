class_name EntityTrackPathNode extends Entity

# 0 is start, 1 is end, 2 is anything in the middle
var node_type : int 
var next_node : int
var entity_translation : Vector3
var visual : VisualNode

func _init(id : int = 0, name : String = "", parent : Entity = null, tree : Tree = null,
node_type_ : int = 0, next_node_ : int = 0, entity_translation_ : Vector3 = Vector3.ZERO,
visual_ : VisualNode = null, visual_parent : Control = null, visual_func : Callable = func(): pass) -> void:
	super._init(id, name, parent, tree)
	node_type = node_type_
	next_node = next_node_
	entity_translation = entity_translation_
	visual = visual_
	if visual_ == null:
		visual = VisualNode.new()
		visual_parent.add_child(visual)
		visual.connected_entity = self
		visual.position = pos_to_canvas_pos(entity_translation)
		visual.gui_input.connect(visual_func.bind(visual))

func get_type_string() -> String:
	return "TrackPathNode"

func to_dict() -> Dictionary:
	var dict := super.to_dict()
	var path_node := { "node_type" : node_type }
	if (node_type != 1): path_node.set("next_node", next_node)
	dict.set("path_node", path_node)
	dict.set("entity_translation", [entity_translation.x, entity_translation.y, entity_translation.z])
	return dict

func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	var path_node = data.get("path_node", {})
	node_type = path_node.get("node_type", -1)
	next_node = path_node.get("next_node", -1)
	var trans_arr : Array[float] = data.get("entity_translation", [0.0, 0.0, 0.0])
	entity_translation = Vector3(trans_arr[0], trans_arr[1], trans_arr[2])

func destroy() -> void:
	if tree_item: tree_item.destroy()
	visual.queue_free()
	visual = null
	for c in entity_children:
		c.destroy()

static func get_creation_ui(tree : Tree, global_id : int, done_func : Callable,
visual_parent : Control = null, visual_func : Callable = func(): pass) -> Control:
	var root := super.get_creation_ui(tree, global_id, done_func)
	root.size = Vector2(300.0, 320.0)
	root.position = (viewport_size - root.size) * 0.5
	var line_edit : LineEdit = root.get_node("line_edit")
	var create_button : Button = root.get_node("create_button")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	var title : Label = root.get_node("title")
	title.text = "Create TrackPathNode Node"
	
	var seperator1 := HSeparator.new()
	root.add_child(seperator1)
	seperator1.size = Vector2(260.0, 16.0)
	seperator1.position = Vector2(20.0, 80.0)
	
	var label_translation := Label.new()
	root.add_child(label_translation)
	label_translation.text = "Translation"
	label_translation.position = Vector2(16.0, 92.0)
	
	var slider_x = GenericSlider.new("X", -200.0, 0.0, 200.0, 5)
	slider_x.position = Vector2(16.0, 116.0)
	root.add_child(slider_x)
	
	var slider_y = GenericSlider.new("Y", -200.0, 0.0, 200.0, 5)
	slider_y.position = Vector2(16.0, 140.0)
	root.add_child(slider_y)
	
	var slider_z = GenericSlider.new("Z", -200.0, 0.0, 200.0, 5)
	slider_z.position = Vector2(16.0, 164.0)
	root.add_child(slider_z)
	
	var label_type := Label.new()
	root.add_child(label_type)
	label_type.text = "Node Type"
	label_type.position = Vector2(16.0, 200.0)
	
	var spinbox_type := SpinBox.new()
	root.add_child(spinbox_type)
	spinbox_type.name = "spinbox_type"
	spinbox_type.position = Vector2(160.0, 200.0)
	
	var label_next := Label.new()
	root.add_child(label_next)
	label_next.text = "Next Node"
	label_next.position = Vector2(16.0, 240.0)
	
	var spinbox_next := SpinBox.new()
	root.add_child(spinbox_next)
	spinbox_next.name = "spinbox_next"
	spinbox_next.position = Vector2(160.0, 240.0)
	
	create_button.position.y = 280.0
	create_button.pressed.connect(
		func():
			EntityTrackPathNode.new(global_id, line_edit.text, tree.get_selected().get_metadata(0), tree,
			int(spinbox_type.value), int(spinbox_next.value),
			Vector3(slider_x.get_value(), slider_y.get_value(), slider_z.get_value()),
			null, visual_parent, visual_func
			)
			done_func.call(0)
			root.queue_free()
	)
	
	return root

func get_edit_ui(done_func : Callable) -> Control:
	var root : Panel = get_creation_ui(null, 0, done_func)
	var title : Label = root.get_node("title")
	title.text = "Edit TrackPathNode Node"
	var create_button : Button = root.get_node("create_button")
	var line_edit : LineEdit = root.get_node("line_edit")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	
	line_edit.text = entity_name
	root.get_node("GenericSliderX").set_value(entity_translation.x)
	root.get_node("GenericSliderY").set_value(entity_translation.y)
	root.get_node("GenericSliderZ").set_value(entity_translation.z)
	root.get_node("spinbox_type").value = node_type
	root.get_node("spinbox_next").value = next_node
	
	create_button.text = "Confirm"
	create_button.pressed.connect(
		func():
			entity_name = line_edit.text
			entity_translation.x = root.get_node("GenericSliderX").get_value()
			entity_translation.y = root.get_node("GenericSliderY").get_value()
			entity_translation.z = root.get_node("GenericSliderZ").get_value()
			visual.position = pos_to_canvas_pos(entity_translation)
			node_type = int(root.get_node("spinbox_type").value)
			next_node = int(root.get_node("spinbox_next").value)
			tree_item.set_text(0, str(entity_id ,"| ", entity_name, " (", entity_type, ")"))
			done_func.call(1)
			root.queue_free()
	)
	return root

func pos_to_canvas_pos(pos : Vector3) -> Vector2:
	return Vector2(pos.x / 0.44 + 680.0, pos.z / 0.44 + 460.0)
