class_name EntityTrack extends Entity

var track : Track

func _init() -> void:
	entity_type = "Track"

func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.set("track", track.to_dict())
	return dict

func from_dict(data : Dictionary) -> void:
	super.to_dict()
	track.from_dict(data.get("track", {}))
