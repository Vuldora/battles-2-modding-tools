class_name EntityMapSideReference extends Entity

var map_side_reference : MapSideReference
var entity_rotation : Vector3

func _init() -> void:
	entity_type = "MapSideReference"

func to_dict() -> Dictionary:
	var data := super.to_dict()
	data.set("map_side_reference", map_side_reference.to_dict())
	data.set("entity_rotation", [entity_rotation.x, entity_rotation.y, entity_rotation.z])
	return data
