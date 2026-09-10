class_name GenericSlider extends Control

var label : Label
var value_label : Label
var slider : Slider

func _init(text : String, minv : float, defv : float, maxv : float, ticks : int) -> void:
	label = Label.new()
	add_child(label)
	label.text = text
	
	value_label = Label.new()
	add_child(value_label)
	value_label.text = str(defv)
	value_label.position.x += 240.0
	
	slider = HSlider.new()
	add_child(slider)
	slider.position.x = 48.0
	slider.size = Vector2(184.0, 24.0)
	slider.min_value = minv
	slider.value = defv
	slider.max_value = maxv
	slider.tick_count = ticks
	slider.ticks_on_borders = true
	slider.value_changed.connect(
		func(val):
			value_label.text = str(val)
	)

func get_value() -> float:
	return slider.value
