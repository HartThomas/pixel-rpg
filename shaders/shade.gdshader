shader_type canvas_item;
uniform vec4 color: source_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(color.rgb, tex_color.a * color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
