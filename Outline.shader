// Outline.shader
shader_type spatial;
render_mode cull_front, unshaded, depth_draw_alpha_prepass;

uniform vec4 outline_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float thickness : hint_range(0.0, 0.2) = 0.05;

void vertex() {
    // normal vektörü boyunca öne itiyoruz
    VERTEX += NORMAL * thickness;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA  = outline_color.a;
}
