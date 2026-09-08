class_name Header

var version_code : int
var id_gen_current_id : int
var root : Entity

func to_dict() -> Dictionary:
	return {
		"version_code" : version_code,
		"id_gen_current_id" : id_gen_current_id,
		"root" : root.to_dict()
	}

func from_dict(data : Dictionary) -> void:
	version_code = data.get("version_code", -1)
	id_gen_current_id = data.get("id_gen_current_id", -1)
	root = Entity.new()
	root.from_dict(data.get("root", null))
