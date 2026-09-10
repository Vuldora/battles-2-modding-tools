class_name EntityTrackPathNode extends Entity

# 0 is start, 1 is end, 2 is anything in the middle
var node_type : int 
var next_node : int
var entity_translation : Vector3

func _init() -> void:
	entity_type = "TrackPathNode"

func to_dict() -> Dictionary:
	var dict := super.to_dict()
	var path_node := { "node_type" : node_type }
	if (node_type != 1): path_node.set("next_node", next_node)
	dict.set("path_node", path_node)
	dict.set("entity_translation", [entity_translation.x, entity_translation.y, entity_translation.z])
	return dict

func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	var path_node = data.get("path_node", {})
	node_type = path_node.get("node_type", -1)
	next_node = path_node.get("next_node", -1)
	var trans_arr : Array[float] = data.get("entity_translation", [0.0, 0.0, 0.0])
	entity_translation = Vector3(trans_arr[0], trans_arr[1], trans_arr[2])
