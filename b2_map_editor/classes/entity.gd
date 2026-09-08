class_name Entity

var entity_id : int
var entity_name : String
var entity_type : String
var entity_children : Array[Entity]
var tree_item : TreeItem

func  _init(id : int = 0, name : String = "", parent : Entity = null, tree : Tree = null) -> void:
	entity_id = id
	entity_name = name
	entity_type = "Empty"
	if (parent != null):
		parent.entity_children.append(self)
		tree_item = tree.create_item(parent.tree_item) if tree != null else null
	else:
		tree_item = tree.create_item() if tree != null else null
	if (tree_item != null):
		tree_item.set_text(0, str(entity_name, " (", entity_type ,")"))
		tree_item.set_metadata(0, self)

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
	entity_id = data.get("entity_id", -1)
	entity_name = data.get("entity_name", "ErrorMissingName")
	entity_type = data.get("entity_type", "ErrorMissingType")
	var children_dicts = data.get("entity_children", [])
	for c in children_dicts:
		var entity : Entity = Entity.new()
		entity.from_dict(c)
		entity_children.append(entity)
