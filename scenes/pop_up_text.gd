extends Label

var new_text : String = 'skdfjhskdjhf'
var new_color = Color('BLACK')
var new_position :Vector2

func _ready() -> void:
	text = new_text
	add_theme_color_override('font_color', new_color)
	position = new_position
	rise_and_fade()
	z_index = 100

func rise_and_fade():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, 'position:y', position.y - 50.0, 1.0)
	tween.tween_property(self, 'modulate:a', 0.0, 1.0)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
