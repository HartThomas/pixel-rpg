shader_type canvas_item;

uniform float shadow_height = 20.0;
uniform float softness = 10.0;
uniform vec2 light_dir = vec2(-1.0, 1.0); // direction from which light comes
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.4);

void fragment() {
    // Original texture color
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Shadow offset
    vec2 shadow_offset = normalize(light_dir) * shadow_height * TEXTURE_PIXEL_SIZE;

    // Sample the shadow "behind" the sprite
    vec4 shadow_sample = texture(TEXTURE, UV - shadow_offset);

    // Create softness mask
    float dist = length(shadow_offset) / shadow_height;
    float softness_factor = smoothstep(0.0, 1.0, 1.0 - dist) * shadow_sample.a;

    // Output: either shadow or original texture
    vec4 result_color = tex_color;

    // Blend the shadow in where original is transparent
    if (tex_color.a < 0.1 && shadow_sample.a > 0.1) {
        result_color = shadow_color * softness_factor;
    }

    COLOR = result_color;
}
