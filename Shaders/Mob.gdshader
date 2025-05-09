shader_type canvas_item;

#include "res://Shaders/Globals.gdshaderinc"

// hint_range() restricts values to a range (with min/max/step).
instance uniform float red_factor : hint_range(0.0, 1.0) = 1.0;
instance uniform float green_factor : hint_range(0.0, 1.0) = 1.0;
instance uniform float blue_factor : hint_range(0.0, 1.0) = 1.0;
instance uniform float alpha : hint_range(0.0, 1.0) = 1.0;

instance uniform int illumination_mask = 7;
instance uniform bool soft_illumination_cutoff = false;

#include "res://Shaders/Lighting.gdshaderinc"

void vertex() {
	if (in_game) {
		// Creates underwater effect
		VERTEX.x += sin(VERTEX.y + TIME * 2.0) * 3.0;
	}
}

void fragment() {
	// COLOR.a > 0.0001 makes it so we don't modify transparent pixels
	if (in_game && COLOR.a > 0.0001) {
		if (within_shadow(FRAGCOORD.xy)) {
			COLOR = vec4(0, 0, 0, COLOR.a);
		} else {
			// modifies rgba values by uniforms
			COLOR.rgb = vec3(COLOR.r * red_factor, COLOR.g * green_factor, COLOR.b * blue_factor);
			COLOR.a = alpha;

			// makes it so mob fades out as they get farther away from player_pos / gets out of player's sight
			vec4 light_influence = get_light_influence(FRAGCOORD.xy);
			vec3 light_colors = light_influence.rgb;
			float light_brightness = light_influence.a;
			float invisibility = 1.0 - 3.0 * light_brightness;

			vec4 final_color = vec4((COLOR.rgb + light_colors) * light_brightness, COLOR.a);
			if (final_color.rgb == vec3(0, 0, 0))
				COLOR = vec4(0, 0, 0, 0);
			else {
				if (soft_illumination_cutoff)
					COLOR = vec4((COLOR.rgb + light_colors) * light_brightness, COLOR.a - invisibility);
				else
					COLOR = vec4((COLOR.rgb + light_colors) * light_brightness, COLOR.a);
			}
		}
	}
}
