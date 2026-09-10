class_name MapSideReference

var side : int
var mode : int

func _init(side_ : int, mode_ : int) -> void:
	side = side_
	mode = mode_

func to_dict() -> Dictionary:
	return {
		"side" : side,
		"mode" : mode
	}

func from_dict(data : Dictionary) -> void:
	side = data.get("side", 0)
	mode = data.get("mode", 0)
