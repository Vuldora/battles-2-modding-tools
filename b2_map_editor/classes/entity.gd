class_name Entity

var entity_id : int
var entity_name : String
var entity_type : String
var entity_children : Array[Entity]

func  _init() -> void:
	entity_type = "Empty"

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
