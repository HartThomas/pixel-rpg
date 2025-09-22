extends CanvasLayer

@export var slide_distance: float = 200.0
@export var slide_duration: float = 0.5
@onready var control: Control = $Control
@onready var cooldown_progress: ProgressBar = $CooldownBorder/CooldownProgress
@onready var cooldown_texture: TextureRect = $CooldownBorder/CooldownTexture
@onready var inventory_panel_3: Panel = $Control/Container/Equipment/GridContainer2/InventoryPanel3
@onready var cooldown_error: TextureRect = $CooldownBorder/CooldownError
@onready var _25: TextureRect = $"DamageBorder/25"
@onready var _50: TextureRect = $"DamageBorder/50"
@onready var _75: TextureRect = $"DamageBorder/75"
@onready var _100: TextureRect = $"DamageBorder/100"
const TOOLTIP = preload("res://scenes/tooltip.tscn")
var cooldown_showing

var start_position: Vector2
var target_position: Vector2
var is_shown: bool = false
var tt

@onready var tween := create_tween()

func _ready():
	start_position = control.position
	target_position = start_position + Vector2(slide_distance, 0)
	control.position = start_position
	cooldown_texture.texture = null
	inventory_panel_3.connect('weapon_changed', change_cooldown)
	if InventoryManager.equipped[8].value is Weapon:
		WeaponScript.connect("attack_attempt_failed", show_cooldown_error)
	_25.modulate.a = 0
	_50.modulate.a = 0
	_75.modulate.a = 0
	_100.modulate.a = 0
	var new_tt = TOOLTIP.instantiate()
	new_tt.text = str(PlayerManager.player_stats.health) + '/' + str(PlayerManager.player_stats.max_health) 
	new_tt.parent_item = self
	new_tt.hide()
	add_child(new_tt)
	tt = new_tt

func show_gui():
	if is_shown: return
	is_shown = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(control, "position", target_position, slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func hide_gui():
	if not is_shown: return
	is_shown = false
	tween.kill()
	tween = create_tween()
	tween.tween_property(control, "position", start_position, slide_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func change_cooldown(weapon : Weapon):
	cooldown_texture.texture = weapon.texture
	cooldown_progress.max_value = 1.0
	cooldown_showing = weapon

var grey = Color('#5c5b5c')
var red = Color('#8d1e1e')
var green = Color('#738860')

func _process(delta: float) -> void:
	if cooldown_showing:
		var progress = 1.0 - CooldownManager.get_cooldown_progress(cooldown_showing, "attack")
		var steps = 5
		var snapped = round(progress * steps) / steps
		cooldown_progress.value = snapped * cooldown_progress.max_value
		
		# Switch color when done
		if progress >= 1.0:
			# Cooldown finished → green
			var style_ready = StyleBoxFlat.new()
			style_ready.bg_color = green
			cooldown_progress.add_theme_stylebox_override("fill", style_ready)
			cooldown_progress.add_theme_stylebox_override("fg", style_ready)
		else:
			# Cooldown ticking → red
			var style_cooldown = StyleBoxFlat.new()
			style_cooldown.bg_color = red
			cooldown_progress.add_theme_stylebox_override("fill", style_cooldown)

var cooldown_tween: Tween

func show_cooldown_error():
	if cooldown_tween and cooldown_tween.is_running():
		cooldown_tween.kill()
	cooldown_error.modulate.a = 1
	cooldown_tween = get_tree().create_tween()
	cooldown_tween.tween_property(cooldown_error, "modulate:a", 0.0, 0.5)

var tweens = {}

func fade_out(node: Node):
	if tweens.has(node) and tweens[node].is_running():
		tweens[node].kill()
	node.modulate.a = 1
	var t = get_tree().create_tween()
	t.tween_property(node, "modulate:a", 0.0, 0.5)
	tweens[node] = t

func after_damage_above_75(): fade_out(_25)
func after_damage_above_50(): fade_out(_50)
func after_damage_above_25(): fade_out(_75)
func after_damage_above_0():  fade_out(_100)

var tooltips = []

func _on_health_bar_mouse_entered() -> void:
	tt.position = get_viewport().get_mouse_position() + Vector2(8,-25)
	tt.show()

func _on_health_bar_mouse_exited() -> void:
	tt.hide()

func update_healthbar_tooltip():
	tt.text = str(PlayerManager.player_stats.health) + '/' + str(PlayerManager.player_stats.max_health) 
	tt.update_text()
