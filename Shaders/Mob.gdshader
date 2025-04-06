shader_type canvas_item;

// Prevents shader from being previewed out of game
uniform bool IN_GAME = false;

// hint_range() restricts values to a range (with min/max/step).
uniform float red_factor : hint_range(0.0, 1.0) = 1.0;
uniform float green_factor : hint_range(0.0, 1.0) = 1.0;
uniform float blue_factor : hint_range(0.0, 1.0) = 1.0;

// Parameter to control the alpha factor
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

uniform float max_distance = 200.0;
uniform vec2 player_pos = vec2(0, 0);
uniform vec2 mouse_pos = vec2(0, 0);

void fragment() {
	// COLOR.a > 0.0001 makes it so we don't modify transparent pixels
	if (IN_GAME && COLOR.a > 0.0001) {
		// modifies rgba values by uniforms
		COLOR.rgb = vec3(COLOR.r * red_factor, COLOR.g * green_factor, COLOR.b * blue_factor);
		COLOR.a = alpha;
		
		// makes it so mob fades out as they get farther away from player_pos
		float visibility = 1.0 - (distance(FRAGCOORD.xy, player_pos) / max_distance);
		COLOR = vec4(COLOR.rgb * visibility, COLOR.a);
	}
}
