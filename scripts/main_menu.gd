extends Control




const target_scene_path = "res://scenes/adventure.tscn"

var loading_status : int
var progress : Array[float]

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var v_box_container: Control = $VBoxContainer

#func _on_start_button_button_down() -> void:
	#var adventure = load("res://scenes/adventure.tscn")
	#get_tree().change_scene_to_packed(adventure)

func _on_start_button_button_down() -> void:
	# Request to load the target scene:
	ResourceLoader.load_threaded_request(target_scene_path)
	v_box_container.visible = true

func _process(_delta: float) -> void:
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100 # Change the ProgressBar value
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to the target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene_path))
		ResourceLoader.THREAD_LOAD_FAILED:
			# Well some error happend:
			print("Error. Could not load Resource")
