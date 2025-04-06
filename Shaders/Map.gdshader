shader_type canvas_item;

// Prevents shader from being previewed out of game
uniform bool IN_GAME = false;

const float sight_angle = PI/15.0;

uniform float max_radius = 200.0;
uniform float max_sight_distance = 500.0; 
uniform vec2 player_pos = vec2(0, 0);
uniform vec2 mouse_pos = vec2(0, 0);

void fragment() {
	if (IN_GAME) {
		vec2 player_to_mouse = mouse_pos - player_pos;
		vec2 player_to_frag = FRAGCOORD.xy - player_pos;
	
		// gets the angle between the vector spanning from player to mouse and player to frag
		float angle = acos(dot(normalize(player_to_mouse), normalize(player_to_frag)));
		
		float radius_visibility = 1.0 - (distance(FRAGCOORD.xy, player_pos) / max_radius);
		// Horrible to look at; at some point I will try to make it look less... horrible
		float sight_visibility = 1.0 - clamp(((distance(FRAGCOORD.xy, player_pos) - 500.0) / max_sight_distance), 0.0, 1.0) - (angle / sight_angle);
		
		if (angle < sight_angle && sight_visibility >= radius_visibility) {
			// frag is in player's look direction
			COLOR = vec4(COLOR.rgb * sight_visibility, 1);
		} else {
			// frag is not in player's look direction
			COLOR = vec4(COLOR.rgb * radius_visibility, 1);
		}
	}
}
