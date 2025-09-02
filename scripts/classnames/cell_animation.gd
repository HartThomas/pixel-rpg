extends Resource

class_name CellAnimation

@export var animation_name : String
@export var texture : Texture2D
@export var offset : Vector2
@export var columns : int 
@export var rows : int
@export var used_columns : int
@export var time_per_frame : Array[float]
@export var loop : bool
@export var despawn : bool

func to_sprite_frames(name: String = animation_name, frame_size: Vector2i = Vector2i(32,32)) -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.add_animation(name)
	frames.set_animation_loop(name, loop)

	var image = texture.get_image()
	for y in range(rows):
		for x in range(used_columns):
			var rect = Rect2(x * frame_size.x, y * frame_size.y, frame_size.x, frame_size.y)
			var frame_image = image.get_region(rect)
			var frame_tex = ImageTexture.create_from_image(frame_image)
			frames.add_frame(name, frame_tex)
	return frames

func on_animation_end():
	pass
