class_name EntityTrack extends Entity

var track : Track

func _init(id : int = 0, name : String = "", parent : Entity = null, tree : Tree = null,
track_ : Track = null ) -> void:
	super._init(id, name, parent, tree)
	track = track_

func get_type_string() -> String:
	return "Track"

func to_dict() -> Dictionary:
	var dict := super.to_dict()
	dict.set("track", track.to_dict())
	return dict

func from_dict(data : Dictionary) -> void:
	super.to_dict()
	track.from_dict(data.get("track", {}))

static func get_creation_ui(tree : Tree, global_id : int, done_func : Callable) -> Control:
	var root := super.get_creation_ui(tree, global_id, done_func)
	root.size = Vector2(780.0, 600.0)
	root.position = (viewport_size - root.size) * 0.5
	var line_edit : LineEdit = root.get_node("line_edit")
	var create_button : Button = root.get_node("create_button")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	var title : Label = root.get_node("title")
	title.text = "Create Track Node"
	var exit_button : Button = root.get_node("exit_button")
	exit_button.position = Vector2(740.0, 8.0)
	
	var separator1 := HSeparator.new()
	root.add_child(separator1)
	separator1.size = Vector2(708.0, 24.0)
	separator1.position = Vector2(16.0, 76.0)
	
	var label_y : Array[float] = [96.0]
	
	var add_label = func(text, x):
		var label := Label.new()
		root.add_child(label)
		label.text = text
		label.position = Vector2(x, label_y[0])
		label_y[0] += 64.0
	
	for t in [
		"Side",
		"Width",
		"Sent or Naturals",
		"Bloon type filter bitmask (natural)",
		"Bloon type filter string (natural)",
		"Bloon feature inclusive filter bitmask (natural)",
		"Bloon feature exclusive filter bitmask (natural)"
		]:
				add_label.call(t, 16.0)
	label_y[0] = 96.0
	for t in [
		"Exclude from auto track targeting",
		"Source Path ID",
		"Teleporter Track",
		"Bloon type filter bitmask (sent)",
		"Bloon type filter string (sent)",
		"Bloon feature inclusive filter bitmask (sent)",
		"Bloon feature exclusive filter bitmask (sent)",
	]:
		add_label.call(t, 406.0)
	
	var spinbox_side := SpinBox.new()
	root.add_child(spinbox_side)
	spinbox_side.name = "spinbox_side"
	spinbox_side.position = Vector2(16.0, 120.0)
	
	var slider_width := GenericSlider.new("", 0.0, 3.0, 10.0, 6)
	root.add_child(slider_width)
	slider_width.name = "slider_width"
	slider_width.position = Vector2(-32.0, 184.0)
	
	var option_button_bloon_source := OptionButton.new()
	root.add_child(option_button_bloon_source)
	option_button_bloon_source.add_item("Natural", 1)
	option_button_bloon_source.add_item("Sent", 2)
	option_button_bloon_source.add_item("Both", 3)
	option_button_bloon_source.name = "option_button_bloon_source"
	option_button_bloon_source.size = Vector2(160.0, 32.0)
	option_button_bloon_source.position = Vector2(16.0, 252.0)
	
	var line_edit_type_bit_nats := LineEdit.new()
	root.add_child(line_edit_type_bit_nats)
	line_edit_type_bit_nats.name = "line_edit_type_bit_nats"
	line_edit_type_bit_nats.size = Vector2(160.0, 32.0)
	line_edit_type_bit_nats.position = Vector2(16.0, 316.0)
	line_edit_type_bit_nats.text = "4294967295"
	
	var line_edit_type_str_nats := LineEdit.new()
	root.add_child(line_edit_type_str_nats)
	line_edit_type_str_nats.name = "line_edit_type_str_nats"
	line_edit_type_str_nats.size = Vector2(160.0, 32.0)
	line_edit_type_str_nats.position = Vector2(16.0, 380.0)
	line_edit_type_str_nats.text = "ALL"
	
	var line_edit_feat_inc_nats := LineEdit.new()
	root.add_child(line_edit_feat_inc_nats)
	line_edit_feat_inc_nats.name = "line_edit_feat_inc_nats"
	line_edit_feat_inc_nats.size = Vector2(160.0, 32.0)
	line_edit_feat_inc_nats.position = Vector2(16.0, 444.0)
	line_edit_feat_inc_nats.text = "0"
	
	var line_edit_feat_exc_nats := LineEdit.new()
	root.add_child(line_edit_feat_exc_nats)
	line_edit_feat_exc_nats.name = "line_edit_feat_exc_nats"
	line_edit_feat_exc_nats.size = Vector2(160.0, 32.0)
	line_edit_feat_exc_nats.position = Vector2(16.0, 508.0)
	line_edit_feat_exc_nats.text = "0"
	
	var check_exclude_auto := CheckBox.new()
	root.add_child(check_exclude_auto)
	check_exclude_auto.name = "check_exclude_auto"
	check_exclude_auto.position = Vector2(406.0, 120.0)
	
	var spinbox_source := SpinBox.new()
	root.add_child(spinbox_source)
	spinbox_source.name = "spinbox_source"
	spinbox_source.position = Vector2(406.0, 184.0)
	
	var check_teleporter := CheckBox.new()
	root.add_child(check_teleporter)
	check_teleporter.name = "check_teleporter"
	check_teleporter.position = Vector2(406.0, 248.0)
	
	var line_edit_type_bit_sent := LineEdit.new()
	root.add_child(line_edit_type_bit_sent)
	line_edit_type_bit_sent.name = "line_edit_type_bit_sent"
	line_edit_type_bit_sent.size = Vector2(160.0, 32.0)
	line_edit_type_bit_sent.position = Vector2(406.0, 316.0)
	line_edit_type_bit_sent.text = "4294967295"
	
	var line_edit_type_str_sent := LineEdit.new()
	root.add_child(line_edit_type_str_sent)
	line_edit_type_str_sent.name = "line_edit_type_str_sent"
	line_edit_type_str_sent.size = Vector2(160.0, 32.0)
	line_edit_type_str_sent.position = Vector2(406.0, 380.0)
	line_edit_type_str_sent.text = "ALL"
	
	var line_edit_feat_inc_sent := LineEdit.new()
	root.add_child(line_edit_feat_inc_sent)
	line_edit_feat_inc_sent.name = "line_edit_feat_inc_sent"
	line_edit_feat_inc_sent.size = Vector2(160.0, 32.0)
	line_edit_feat_inc_sent.position = Vector2(406.0, 444.0)
	line_edit_feat_inc_sent.text = "0"
	
	var line_edit_feat_exc_sent := LineEdit.new()
	root.add_child(line_edit_feat_exc_sent)
	line_edit_feat_exc_sent.name = "line_edit_feat_exc_sent"
	line_edit_feat_exc_sent.size = Vector2(160.0, 32.0)
	line_edit_feat_exc_sent.position = Vector2(406.0, 508.0)
	line_edit_feat_exc_sent.text = "0"
	
	create_button.position = Vector2(360.0, 560.0)
	create_button.pressed.connect(
		func():
			var track_ = Track.new(
				int(spinbox_side.value),
				slider_width.get_value(),
				check_teleporter.button_pressed,
				check_exclude_auto.button_pressed,
				option_button_bloon_source.get_selected_id(),
				int(line_edit_type_bit_nats.text),
				line_edit_type_str_nats.text,
				int(line_edit_feat_inc_nats.text),
				int(line_edit_feat_exc_nats.text),
				int(line_edit_type_bit_sent.text),
				line_edit_type_str_sent.text,
				int(line_edit_feat_inc_sent.text),
				int(line_edit_feat_exc_sent.text),
				int(spinbox_source.value)
				)
			EntityTrack.new(global_id, line_edit.text, tree.get_selected().get_metadata(0), tree,
			track_)
			done_func.call(0)
			root.queue_free()
	)
	
	return root

func get_edit_ui(done_func : Callable) -> Control:
	var root : Panel = get_creation_ui(null, 0, done_func)
	var title : Label = root.get_node("title")
	title.text = "Edit Empty Node"
	var create_button : Button = root.get_node("create_button")
	var line_edit : LineEdit = root.get_node("line_edit")
	for c in create_button.pressed.get_connections():
		create_button.pressed.disconnect(c.callable)
	
	root.get_node("spinbox_side").value = track.side
	root.get_node("slider_width").set_value(track.width)
	root.get_node("check_teleporter").button_pressed = track.is_teleporter_track
	root.get_node("check_exclude_auto").button_pressed = track.exclude_from_auto_track_targeting
	root.get_node("option_button_bloon_source").select(track.track_bloon_source_bitmask - 1)
	root.get_node("line_edit_type_bit_nats").text = str(track.track_round_bloon_type_filte_bitmask)
	root.get_node("line_edit_type_str_nats").text = track.track_round_bloon_type_filter_string
	root.get_node("line_edit_feat_inc_nats").text = str(track.track_round_bloon_feature_inclusive_filter_bitmask)
	root.get_node("line_edit_feat_exc_nats").text = str(track.track_round_bloon_feature_exclusive_filter_bitmask)
	root.get_node("line_edit_type_bit_sent").text = str(track.track_opponent_bloon_type_filte_bitmask)
	root.get_node("line_edit_type_str_sent").text = track.track_opponent_bloon_type_filter_string
	root.get_node("line_edit_feat_inc_sent").text = str(track.track_opponent_bloon_feature_inclusive_filter_bitmask)
	root.get_node("line_edit_feat_exc_sent").text = str(track.track_opponent_bloon_feature_exclusive_filter_bitmask)
	root.get_node("spinbox_source").value = track.source_path_id
	line_edit.text = entity_name
	
	create_button.text = "Confirm"
	create_button.pressed.connect(
		func():
			track.side = int(root.get_node("spinbox_side").value)
			track.width = root.get_node("slider_width").get_value()
			track.is_teleporter_track = root.get_node("check_teleporter").button_pressed
			track.exclude_from_auto_track_targeting = root.get_node("check_exclude_auto").button_pressed
			track.track_bloon_source_bitmask = root.get_node("option_button_bloon_source").get_selected_id()
			track.track_round_bloon_type_filte_bitmask = int(root.get_node("line_edit_type_bit_nats").text)
			track.track_round_bloon_type_filter_string = root.get_node("line_edit_type_str_nats").text
			track.track_round_bloon_feature_inclusive_filter_bitmask = int(root.get_node("line_edit_feat_inc_nats").text)
			track.track_round_bloon_feature_exclusive_filter_bitmask = int(root.get_node("line_edit_feat_exc_nats").text)
			track.track_opponent_bloon_type_filte_bitmask = int(root.get_node("line_edit_type_bit_sent").text)
			track.track_opponent_bloon_type_filter_string = root.get_node("line_edit_type_str_sent").text
			track.track_opponent_bloon_feature_inclusive_filter_bitmask = int(root.get_node("line_edit_feat_inc_sent").text)
			track.track_opponent_bloon_feature_exclusive_filter_bitmask = int(root.get_node("line_edit_feat_exc_sent").text)
			track.source_path_id = int(root.get_node("spinbox_source").value)
			entity_name = line_edit.text
			tree_item.set_text(0, str(entity_id ,"| ", entity_name, " (", entity_type, ")"))
			done_func.call(1)
			root.queue_free()
	)
	return root
