class_name Track

var side : int
var width : float
var is_teleporter_track : bool
var exclude_from_auto_track_targeting : bool
## 1 is nats, 2 is player sent, 0 is *probably* both
var track_bloon_source_bitmask : int 
var track_round_bloon_type_filte_bitmask : int
var track_round_bloon_type_filter_string : String
var track_round_bloon_feature_inclusive_filter_bitmask : int
var track_round_bloon_feature_exclusive_filter_bitmask : int
var track_opponent_bloon_type_filte_bitmask : int # Filter is mispelled on NK's part
var track_opponent_bloon_type_filter_string : String
var track_opponent_bloon_feature_inclusive_filter_bitmask : int
var track_opponent_bloon_feature_exclusive_filter_bitmask : int
var source_path_id : int

func _init(
	side_ : int = 0,
	width_ : float = 0.0,
	is_teleporter_track_ : bool = false,
	exclude_from_auto_track_targeting_ : bool = false,
	track_bloon_source_bitmask_ : int = 0,
	track_round_bloon_type_filte_bitmask_ : int = 0,
	track_round_bloon_type_filter_string_ : String = "",
	track_round_bloon_feature_inclusive_filter_bitmask_ : int = 0,
	track_round_bloon_feature_exclusive_filter_bitmask_ : int = 0,
	track_opponent_bloon_type_filte_bitmask_ : int = 0,
	track_opponent_bloon_type_filter_string_ : String = "",
	track_opponent_bloon_feature_inclusive_filter_bitmask_ : int = 0,
	track_opponent_bloon_feature_exclusive_filter_bitmask_ : int = 0,
	source_path_id_ : int = 0
) -> void:
	side = side_
	width = width_
	is_teleporter_track = is_teleporter_track_
	exclude_from_auto_track_targeting = exclude_from_auto_track_targeting_
	track_bloon_source_bitmask = track_bloon_source_bitmask_
	track_round_bloon_type_filte_bitmask = track_round_bloon_type_filte_bitmask_
	track_round_bloon_type_filter_string = track_round_bloon_type_filter_string_
	track_round_bloon_feature_inclusive_filter_bitmask = track_round_bloon_feature_inclusive_filter_bitmask_
	track_round_bloon_feature_exclusive_filter_bitmask = track_round_bloon_feature_exclusive_filter_bitmask_
	track_opponent_bloon_type_filte_bitmask = track_opponent_bloon_type_filte_bitmask_
	track_opponent_bloon_type_filter_string = track_opponent_bloon_type_filter_string_
	track_opponent_bloon_feature_inclusive_filter_bitmask = track_opponent_bloon_feature_inclusive_filter_bitmask_
	track_opponent_bloon_feature_exclusive_filter_bitmask = track_opponent_bloon_feature_exclusive_filter_bitmask_
	source_path_id = source_path_id_

func to_dict() -> Dictionary:
	return {
		"side": side,
		"width": width,
		"is_teleporter_track": is_teleporter_track,
		"exclude_from_auto_track_targeting": exclude_from_auto_track_targeting,
		"track_bloon_source_bitmask": track_bloon_source_bitmask,
		"track_round_bloon_type_filte_bitmask": track_round_bloon_type_filte_bitmask,
		"track_round_bloon_type_filter_string": track_round_bloon_type_filter_string,
		"track_round_bloon_feature_inclusive_filter_bitmask": track_round_bloon_feature_inclusive_filter_bitmask,
		"track_round_bloon_feature_exclusive_filter_bitmask": track_round_bloon_feature_exclusive_filter_bitmask,
		"track_opponent_bloon_type_filte_bitmask": track_opponent_bloon_type_filte_bitmask,
		"track_opponent_bloon_type_filter_string": track_opponent_bloon_type_filter_string,
		"track_opponent_bloon_feature_inclusive_filter_bitmask": track_opponent_bloon_feature_inclusive_filter_bitmask,
		"track_opponent_bloon_feature_exclusive_filter_bitmask": track_opponent_bloon_feature_exclusive_filter_bitmask,
		"source_path_id": source_path_id
	}

func from_dict(data : Dictionary) -> void:
	side = data.get("", -1)
	width = data.get("", -1.0)
	is_teleporter_track = data.get("", false)
	exclude_from_auto_track_targeting = data.get("", false)
	track_bloon_source_bitmask = data.get("", 0)
	track_round_bloon_type_filte_bitmask = data.get("", 0)
	track_round_bloon_type_filter_string = data.get("", 0)
	track_round_bloon_feature_inclusive_filter_bitmask = data.get("", 0)
	track_round_bloon_feature_exclusive_filter_bitmask = data.get("", 0)
	track_opponent_bloon_type_filte_bitmask = data.get("", 0)
	track_opponent_bloon_type_filter_string = data.get("", "ErrorMissingString")
	track_opponent_bloon_feature_inclusive_filter_bitmask = data.get("", 0)
	track_opponent_bloon_feature_exclusive_filter_bitmask = data.get("", 0)
	source_path_id = data.get("", -1)
