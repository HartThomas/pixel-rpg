shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform vec2 shadow_direction = vec2(0.5, 0.5); // in pixels
uniform float shadow_strength = 0.5;
uniform vec2 texture_size = vec2(256.0, 256.0); // Size of the whole tileset texture
uniform vec2 tile_size = vec2(32.0, 32.0); // Size of a single tile

void fragment() {
    // Calculate how many tiles wide the atlas is
    vec2 tile_count = texture_size / tile_size;

    // Find which tile we are in (assuming evenly spaced tiles)
    vec2 tile_index = floor(UV * tile_count);

    // Get tile-local UV
    vec2 local_uv = fract(UV * tile_count);

    // Position in pixels from local UV
    vec2 px = local_uv * tile_size;

    // Distance from bottom
    float height_factor = clamp(1.0 - local_uv.y, 0.0, 1.0);

    // Displace within the tile
    vec2 shadow_px = px + shadow_direction * height_factor;

    // Convert back to full-texture UV
    vec2 shadow_uv = (tile_index * tile_size + shadow_px) / texture_size;

    vec4 shadow_col = texture(TEXTURE, shadow_uv);
    shadow_col.rgb *= vec3(0.0);
    shadow_col.a *= shadow_strength;

    COLOR = shadow_col;
}
