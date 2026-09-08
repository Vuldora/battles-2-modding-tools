extends Control

enum EDITING_MODE {
	SENT,
	NATS,
	AREA
}

var global_id_counter : int = 0

const node_tex : Texture2D = preload("res://textures/node.png")
const SAVE_PATH : String = "user://test_map.json"

var editing_mode : EDITING_MODE = EDITING_MODE.SENT

var sent_curr_id : int = 1000
var sent_curr_path_node : int = 0

var nats_curr_id : int = 2000
var nats_curr_path_node : int = 0

var area_curr_id : int = 3000
var area_curr_path_node : int = 0

var test_header : Header
var test_entity : Entity
var data_entity : Entity
var track1_entity : EntityTrack
var track2_entity : EntityTrack
var track1 : Track
var track2 : Track
var tracks_list : Entity
var areas_list : Entity
var map_area_entity : EntityMapArea
var map_area : MapArea
var track1_nodes : Array[Entity]
var track2_nodes : Array[Entity]
var area_nodes : Array[Entity]
var map_side_entity : EntityMapSideReference
var map_side : MapSideReference

func _ready() -> void:
	
	track1 = Track.new()
	track1.side = 2
	track1.width = 3.0
	track1.is_teleporter_track = false
	track1.exclude_from_auto_track_targeting = false
	track1.track_bloon_source_bitmask = 2 
	track1.track_round_bloon_type_filte_bitmask = 4294967295
	track1.track_round_bloon_type_filter_string = "ALL"
	track1.track_round_bloon_feature_inclusive_filter_bitmask = 0
	track1.track_round_bloon_feature_exclusive_filter_bitmask = 0
	track1.track_opponent_bloon_type_filte_bitmask = 4294967295
	track1.track_opponent_bloon_type_filter_string = "ALL"
	track1.track_opponent_bloon_feature_inclusive_filter_bitmask = 0
	track1.track_opponent_bloon_feature_exclusive_filter_bitmask = 0
	track1.source_path_id = 0
	
	track1_entity = EntityTrack.new()
	track1_entity.entity_id = 4
	track1_entity.entity_name = "Track Sent"
	track1_entity.track = track1
	track1_entity.entity_children = track1_nodes
	
	track2 = Track.new()
	track2.side = 2
	track2.width = 3.0
	track2.is_teleporter_track = false
	track2.exclude_from_auto_track_targeting = false
	track2.track_bloon_source_bitmask = 1
	track2.track_round_bloon_type_filte_bitmask = 4294967295
	track2.track_round_bloon_type_filter_string = "ALL"
	track2.track_round_bloon_feature_inclusive_filter_bitmask = 0
	track2.track_round_bloon_feature_exclusive_filter_bitmask = 0
	track2.track_opponent_bloon_type_filte_bitmask = 4294967295
	track2.track_opponent_bloon_type_filter_string = "ALL"
	track2.track_opponent_bloon_feature_inclusive_filter_bitmask = 0
	track2.track_opponent_bloon_feature_exclusive_filter_bitmask = 0
	track2.source_path_id = 0
	
	track2_entity = EntityTrack.new()
	track2_entity.entity_id = 7
	track2_entity.entity_name = "Track Nats"
	track2_entity.track = track2
	track2_entity.entity_children = track2_nodes
	
	tracks_list = Entity.new()
	tracks_list.entity_id = 3
	tracks_list.entity_name = "Tracks"
	tracks_list.entity_children.append(track1_entity)
	tracks_list.entity_children.append(track2_entity)
	
	map_area = MapArea.new()
	map_area.side = "Right"
	map_area.type = "Water"
	map_area.source_entity_id = 0
	map_area.layer = 0
	map_area.elevation_offset = 0.0
	map_area.is_removable = false
	map_area.is_teleporter = false
	map_area.hit_area_offset = 0.0
	map_area.attached_to_bone = false
	
	map_area_entity = EntityMapArea.new()
	map_area_entity.entity_name = "water"
	map_area_entity.entity_id = 6
	map_area_entity.map_area = map_area
	map_area_entity.entity_children = area_nodes
	
	areas_list = Entity.new()
	areas_list.entity_id = 5
	areas_list.entity_name = "Areas"
	areas_list.entity_children.append(map_area_entity)
	
	map_side = MapSideReference.new()
	map_side.mode = 1
	map_side.side = 1
	
	map_side_entity = EntityMapSideReference.new()
	map_side_entity.entity_id = 9
	map_side_entity.entity_name = "left_side"
	map_side_entity.entity_rotation = Vector3(0.0, 0.0, PI)
	map_side_entity.map_side_reference = map_side
	
	data_entity = Entity.new()
	data_entity.entity_id = 2
	data_entity.entity_name = "Data"
	data_entity.entity_children.append(tracks_list)
	data_entity.entity_children.append(areas_list)
	data_entity.entity_children.append(map_side_entity)
	
	test_entity = Entity.new(1, "Root", null, $Tree)
	test_entity.entity_children.append(data_entity)
	
	test_header = Header.new()
	test_header.version_code = 56
	test_header.id_gen_current_id = 160
	test_header.root = test_entity

func _on_save_button_pressed() -> void:
	var data := test_header.to_dict()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to save")
		return
	file.store_string(JSON.stringify(data, "  "))
	file.close()

func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.is_action_pressed("add_node"):
		match editing_mode:
			EDITING_MODE.SENT:
				add_sent_path_node()
			EDITING_MODE.NATS:
				add_nats_path_node()
			EDITING_MODE.AREA:
				add_area_path_node()

func add_sent_path_node() -> void:
	var mouse_pos := get_global_mouse_position()
	var trs := Sprite2D.new()
	trs.scale = Vector2(0.5, 0.5)
	trs.texture = node_tex
	trs.position = mouse_pos
	trs.modulate = Color(0.0, 1.0, 0.0)
	$Nodes.add_child(trs)
	var etpn := EntityTrackPathNode.new()
	etpn.entity_id = sent_curr_id
	sent_curr_id += 1
	etpn.entity_name = str("node_", sent_curr_path_node)
	if (sent_curr_path_node == 0):
		etpn.node_type = 0
	if (sent_curr_path_node >= 1):
		etpn.node_type = 1
		track1_nodes[sent_curr_path_node - 1].next_node = sent_curr_id - 1
	if (sent_curr_path_node >= 2):
		track1_nodes[sent_curr_path_node - 1].node_type = 2
	sent_curr_path_node += 1
	etpn.entity_translation = Vector3((((mouse_pos.x - 105) * 0.36) - 170), 0.0, ((mouse_pos.y - 40) * 0.36) - 108)
	track1_nodes.append(etpn)

func add_nats_path_node() -> void:
	var mouse_pos := get_global_mouse_position()
	var trs := Sprite2D.new()
	trs.scale = Vector2(0.5, 0.5)
	trs.modulate = Color(1.0, 0.0, 0.0)
	trs.texture = node_tex
	trs.position = mouse_pos
	$Nodes.add_child(trs)
	var etpn := EntityTrackPathNode.new()
	etpn.entity_id = nats_curr_id
	nats_curr_id += 1
	etpn.entity_name = str("node_", nats_curr_path_node)
	if (nats_curr_path_node == 0):
		etpn.node_type = 0
	if (nats_curr_path_node >= 1):
		etpn.node_type = 1
		track2_nodes[nats_curr_path_node - 1].next_node = nats_curr_id - 1
	if (nats_curr_path_node >= 2):
		track2_nodes[nats_curr_path_node - 1].node_type = 2
	nats_curr_path_node += 1
	etpn.entity_translation = Vector3((((mouse_pos.x - 105) * 0.36) - 170), 0.0, ((mouse_pos.y - 40) * 0.36) - 108)
	track2_nodes.append(etpn)

func add_area_path_node() -> void:
	var mouse_pos := get_global_mouse_position()
	var trs := Sprite2D.new()
	trs.scale = Vector2(0.5, 0.5)
	trs.modulate = Color(0.0, 1.0, 1.0)
	trs.texture = node_tex
	trs.position = mouse_pos
	$Nodes.add_child(trs)
	var eman := EntityMapAreaNode.new()
	eman.entity_id = area_curr_id
	area_curr_id += 1
	eman.entity_name = ""
	eman.entity_translation = Vector3((((mouse_pos.x - 105) * 0.36) - 170), 0.0, ((mouse_pos.y - 40) * 0.36) - 108)
	area_nodes.append(eman)

func change_mode(mode: int) -> void:
	editing_mode = mode as EDITING_MODE

func _on_button_create_entity_pressed() -> void:
	test_entity = Entity.new(global_id_counter, $Panel/LineEditName.text, $Tree.get_selected().get_metadata(0), $Tree)
	global_id_counter += 1

func _on_tree_item_selected() -> void:
	$Panel/ButtonCreateEntity.disabled = false

func _on_button_overlay_pressed() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.file_selected.connect(load_overlay.bind(file_dialog))
	add_child(file_dialog)
	file_dialog.popup_centered_clamped.call_deferred()

func load_overlay(path : String, source : FileDialog) -> void:
	var image := Image.load_from_file(path)
	var overlay_texture := ImageTexture.create_from_image(image)
	$TextureRectOverlay.texture = overlay_texture
	source.queue_free()
