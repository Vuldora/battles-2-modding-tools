class_name MapSideReference

var side : int
var mode : int

func to_dict() -> Dictionary:
	return {
		"side" : side,
		"mode" : mode
	}

func from_dict(data : Dictionary) -> void:
	side = data.get("side", -1)
	mode = data.get("mode", -1)
