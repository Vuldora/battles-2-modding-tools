class_name EntityTrack extends Entity

var track : Track

func _init(id : int = 0, name : String = "", parent : Entity = null, tree : Tree = null,
track_ : Track = null ) -> void:
	super._init(id, name, parent, tree)
	track = track_

func get_type_string() -> String:
	return "Track"

func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.set("track", track.to_dict())
	return dict

func from_dict(data : Dictionary) -> void:
	super.to_dict()
	track.from_dict(data.get("track", {}))

static func get_creation_ui(tree : Tree, global_id : int, done_func : Callable) -> Control:
	var root := super.get_creation_ui(tree, global_id, done_func)
	var line_edit : LineEdit = root.get_node("line_edit")
	var create_button : Button = root.get_node("create_button")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	create_button.pressed.connect(
		func():
			EntityTrack.new(global_id, line_edit.text, tree.get_selected().get_metadata(0), tree)
			done_func.call(0)
			root.queue_free()
	)
	return root
