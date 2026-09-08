class_name EntityMapAreaNode extends Entity

var entity_translation : Vector3

func _init() -> void:
	entity_type = "MapArea_Node"

func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.set("entity_translation", [entity_translation.x, entity_translation.y, entity_translation.z])
	return dict

func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	var trans_arr : Array[float] = data.get("entity_translation", [0, 0, 0])
	entity_translation = Vector3(trans_arr[0], trans_arr[1], trans_arr[2])
