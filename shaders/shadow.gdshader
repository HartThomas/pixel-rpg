shader_type canvas_item;

uniform vec2 light_direction = vec2(0.0, -1.0); // normalized
uniform float shadow_length = 1.5;
uniform float blur_strength = 4.0;
uniform float alpha = 0.5;

void fragment() {
    vec2 uv = UV;
    vec4 base = texture(TEXTURE, uv);

    // Shadow origin at bottom center
    vec2 origin_uv = vec2(0.5, 0.5);
    vec2 offset_uv = uv + (uv - origin_uv) * shadow_length * light_direction;

    // Blur pass
    float blur = 0.0;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 blur_offset = vec2(float(x), float(y)) * blur_strength / 512.0;
            blur += texture(TEXTURE, offset_uv + blur_offset).a;
        }
    }
    blur /= 9.0;

    COLOR = vec4(0.0, 0.0, 0.0, blur * alpha);
}
