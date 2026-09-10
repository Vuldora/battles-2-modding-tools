class_name DegreeSlider extends GenericSlider

func _init(text : String) -> void:
	super(text, 0.0, 0.0, 360.0, 9)

func get_rad() -> float:
	return deg_to_rad(slider.value)
