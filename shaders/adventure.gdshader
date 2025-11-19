shader_type canvas_item;

uniform float stripe: hint_range(1.0, 1.0, 0.01) = 0.5;
uniform float scan: hint_range(1.0, 1.0, 0.01) = 0.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float speed: hint_range(1.0, 100.0, 0.1) = 20.0;

void fragment() {
	vec2 uv = UV;
	vec4 color = texture(screen_texture, UV);
	vec4 lcd = vec4(stripe, stripe, stripe, 1.0);
	int rgb_stripe = int(mod(FRAGCOORD.x + TIME * speed, 3.0));
	if (rgb_stripe == 1){
		lcd.r = 1.0;
	} else if (rgb_stripe == 2) {
		lcd.g = 1.0;
	} else {
		lcd.b = 1.0;
	}
	COLOR = color * lcd;
}