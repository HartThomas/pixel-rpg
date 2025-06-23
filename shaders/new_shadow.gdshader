shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform vec2 offset = vec2(50.0, 30.0);

//void fragment() {
    //// Diagnostic: draw RED background so we know shader is working
    //vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV - offset / SCREEN_PIXEL_SIZE);
//}
void fragment() {
    vec2 screen_uv = SCREEN_UV - offset / SCREEN_PIXEL_SIZE;
    vec4 screen_color = texture(SCREEN_TEXTURE, screen_uv);
    vec4 red = vec4(1.0, 0.0, 0.0, 1.0);

    COLOR = mix(red, screen_color, 1.0); // Mix red and sampled texture (just to verify)
    //COLOR = screen_color;
}