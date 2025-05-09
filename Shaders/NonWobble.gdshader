shader_type canvas_item;

#include "res://Shaders/Globals.gdshaderinc"

uniform int illumination_mask = 15;

#include "res://Shaders/Lighting.gdshaderinc"

void fragment() {
	if (in_game) {
		if (within_shadow(FRAGCOORD.xy)) {
			COLOR = vec4(0, 0, 0, COLOR.a);
		} else {
			vec4 light_influence = get_light_influence(FRAGCOORD.xy);
			vec3 light_colors = light_influence.rgb;
			float light_visibility = light_influence.a;

			COLOR = vec4((COLOR.rgb + light_colors) * light_visibility, COLOR.a);
		}
	}
}
