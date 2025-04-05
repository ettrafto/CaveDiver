shader_type canvas_item;

// Prevents shader from being previewed out of game
uniform bool IN_GAME = false;

uniform float max_distance = 200.0;
uniform vec2 player_pos = vec2(0, 0);

void fragment() {
	if (IN_GAME) {
		// makes it so player can only view environment in a radius of 200 pixels
		float visibility = 1.0 - (distance(FRAGCOORD.xy, player_pos) / max_distance);
		COLOR = vec4(COLOR.rgb * visibility, 1);
	}
}
