extends Node2D
@export var light_speed = 200.0
@onready var rock: Sprite2D = $Rock
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var shadow: Sprite2D = $Rock/Shadow
@export var sprite : PackedScene
@onready var point_light_2d_2: PointLight2D = $PointLight2D2

var light_position = Vector2.ZERO

func _process(delta: float) -> void:
	var input = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input.x += 1.0
	if Input.is_action_pressed("ui_left"):
		input.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		input.y += 1.0
	if Input.is_action_pressed("ui_up"):
		input.y -= 1.0

	light_position += input * light_speed * delta
	point_light_2d.position = light_position

func _ready():
	light_position = Vector2(get_viewport().size) / 2.0
	var new_sprite = sprite.instantiate()
	
	new_sprite.sprite_name = 'rock'
	new_sprite.point_lights.append(point_light_2d)
	new_sprite.point_lights.append(point_light_2d_2)
	new_sprite.global_position = Vector2(320, 160)
	add_child(new_sprite)
