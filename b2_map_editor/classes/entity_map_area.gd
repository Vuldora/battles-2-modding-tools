class_name EntityMapArea extends Entity

var map_area : MapArea

func _init() -> void:
	entity_type = "MapArea"

func to_dict() -> Dictionary:
	var data := super.to_dict()
	data.set("map_area", map_area.to_dict())
	return data

func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	var map_area_dict = data.get("map_area")
	map_area = MapArea.new()
	map_area.from_dict(map_area_dict)
