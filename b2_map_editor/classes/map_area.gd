class_name MapArea

## "Left" or "Right"
var side : String
## "Water"
var type : String
var source_entity_id : int
var layer : int
var elevation_offset : float
var is_removable : bool
var is_teleporter : bool
var hit_area_offset : float
var attached_to_bone : bool

func to_dict() -> Dictionary:
	return {
		"side" : side,
		"type" : type,
		"source_entity_id" : source_entity_id,
		"layer" : layer,
		"elevation_offset" : elevation_offset,
		"is_removable" : is_removable,
		"is_teleporter" : is_teleporter,
		"hit_area_offset" : hit_area_offset,
		"attached_to_bone" : attached_to_bone
	}

func from_dict(data : Dictionary) -> void:
	side = data.get("side", "ErrorMissingSide")
	type = data.get("type", "ErrotMissingType")
	source_entity_id = data.get("source_entity_id", -1)
	layer = data.get("layer", -1)
	elevation_offset = data.get("elevation_offset", -1.0)
	is_removable = data.get("is_removable", false)
	hit_area_offset = data.get("hit_area_offset", -1.0)
	attached_to_bone = data.get("attached_to_bone", false)
	
