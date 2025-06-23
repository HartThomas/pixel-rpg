shader_type canvas_item;
render_mode unshaded;

uniform float shadow_length = 50.0;
uniform float shadow_angle_deg = 90.0; // 90 = down
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

void vertex() {
    float angle_rad = radians(shadow_angle_deg);
    vec2 dir = vec2(cos(angle_rad), sin(angle_rad));

    // Project the vertex outward in the light direction
    VERTEX += dir * ((1.0 - UV.y) * shadow_length);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = vec4(shadow_color.rgb, tex.a * shadow_color.a);
}
