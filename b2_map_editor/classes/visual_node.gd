class_name VisualNode extends TextureRect

const node_texture : Texture2D = preload("res://textures/node.png")
var connected_entity : Entity

func _init() -> void:
	size = Vector2(16.0, 16.0)
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture = node_texture
	offset_transform_enabled = true
	offset_transform_position = Vector2(-8.0, -8.0)
