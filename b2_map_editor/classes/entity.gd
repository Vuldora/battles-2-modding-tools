class_name Entity

const viewport_size := Vector2(1280, 720.0)

var entity_id : int
var entity_name : String
var entity_type : String
var entity_children : Array[Entity]
var tree_item : TreeItem

func  _init(id : int = 0, name : String = "", parent : Entity = null, tree : Tree = null) -> void:
	entity_id = id
	entity_name = name
	entity_type = get_type_string()
	if (parent != null):
		parent.entity_children.append(self)
		tree_item = tree.create_item(parent.tree_item) if tree != null else null
	else:
		tree_item = tree.create_item() if tree != null else null
	if (tree_item != null):
		tree_item.set_text(0, str(entity_id ,"| ", entity_name, " (", entity_type, ")"))
		tree_item.set_metadata(0, self)

func get_type_string() -> String:
	return "Empty"

func to_dict() -> Dictionary:
	var data := {
		"entity_id" : entity_id,
		"entity_name" : entity_name,
		"entity_type" : entity_type,
	}
	if entity_children.size() > 0:
		var children_dicts : Array[Dictionary]
		for c in entity_children:
			children_dicts.append(c.to_dict())
		data.set("entity_children", children_dicts)
	return data

func from_dict(data : Dictionary) -> void:
	if (data == null): return
	entity_id = data.get("entity_id", 0)
	entity_name = data.get("entity_name", "")
	entity_type = data.get("entity_type", "")
	var children_dicts = data.get("entity_children", [])
	for c in children_dicts:
		var entity : Entity = Entity.new()
		entity.from_dict(c)
		entity_children.append(entity)

static func get_creation_ui(tree : Tree, global_id : int, done_func : Callable) -> Control:
	var root := Panel.new()
	root.size = Vector2(300.0, 128.0)
	root.position = (viewport_size - root.size) * 0.5
	
	var exit_button := Button.new()
	root.add_child(exit_button)
	exit_button.name = "exit_button"
	exit_button.text = "X"
	exit_button.size = Vector2(32.0, 32.0)
	exit_button.position = Vector2(260.0, 8.0)
	exit_button.pressed.connect(
		func():
			done_func.call(1)
			root.queue_free()
	)
	
	var title := Label.new()
	root.add_child(title)
	title.name = "title"
	title.text = "Create Empty Node"
	title.position = Vector2(8.0 ,8.0)
	
	var label := Label.new()
	root.add_child(label)
	label.text = "Name"
	label.position = Vector2(16.0, 48.0)
	
	var line_edit = LineEdit.new()
	root.add_child(line_edit)
	line_edit.name = "line_edit"
	line_edit.position = Vector2(84.0, 48.0)
	line_edit.size = Vector2(192.0, 32.0)
	
	var create_button := Button.new()
	root.add_child(create_button)
	create_button.text = "Create"
	create_button.name = "create_button"
	create_button.size = Vector2(64.0, 32.0)
	create_button.position = Vector2(118.0, 90.0)
	create_button.pressed.connect(
		func():
			Entity.new(global_id, line_edit.text, tree.get_selected().get_metadata(0), tree)
			done_func.call(0)
			root.queue_free()
	)
	
	return root

func get_edit_ui(done_func : Callable) -> Control:
	var root : Panel = get_creation_ui(null, 0, done_func)
	var title : Label = root.get_node("title")
	title.text = "Edit Empty Node"
	var create_button : Button = root.get_node("create_button")
	var line_edit : LineEdit = root.get_node("line_edit")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	
	line_edit.text = entity_name
	
	create_button.text = "Confirm"
	create_button.pressed.connect(
		func():
			entity_name = line_edit.text
			tree_item.set_text(0, str(entity_id ,"| ", entity_name, " (", entity_type, ")"))
			done_func.call(1)
			root.queue_free()
	)
	return root
