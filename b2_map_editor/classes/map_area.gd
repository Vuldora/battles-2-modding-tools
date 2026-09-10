class_name MapArea

## "Left" or "Right"
var side : String
## "Water"
var type : String
var source_entity_id : int
var layer : int
var elevation_offset : float
var hit_area_offset : float
var is_removable : bool
var is_teleporter : bool
var attached_to_bone : bool

func _init(side_ : String = "",
type_ : String = "",
source_entity_id_ : int = 0,
layer_ : int = 0,
elevation_offset_ : float = 0.0,
hit_area_offset_ : float = 0.0,
is_removable_ : bool = false,
is_teleporter_ : bool = false,
attached_to_bone_ : bool = false
) -> void:
	side = side_
	type = type_
	source_entity_id = source_entity_id_
	layer = layer_
	elevation_offset = elevation_offset_
	hit_area_offset = hit_area_offset_
	is_removable = is_removable_
	is_teleporter = is_teleporter_
	attached_to_bone = attached_to_bone_

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
	side = data.get("side", "")
	type = data.get("type", "")
	source_entity_id = data.get("source_entity_id", 0)
	layer = data.get("layer", 0)
	elevation_offset = data.get("elevation_offset", 0.0)
	is_removable = data.get("is_removable", false)
	hit_area_offset = data.get("hit_area_offset", 0.0)
	attached_to_bone = data.get("attached_to_bone", false)
	
