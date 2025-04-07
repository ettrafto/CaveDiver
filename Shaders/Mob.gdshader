shader_type canvas_item;

// Prevents shader from being previewed out of game
global uniform bool in_game = false;
global uniform vec2 player_pos = vec2(0, 0);
global uniform vec2 mouse_pos = vec2(0, 0);

// hint_range() restricts values to a range (with min/max/step).
uniform float red_factor : hint_range(0.0, 1.0) = 1.0;
uniform float green_factor : hint_range(0.0, 1.0) = 1.0;
uniform float blue_factor : hint_range(0.0, 1.0) = 1.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

// Used by get_visibility_modifier
const float MAX_SIGHT_ANGLE = radians(7.2)/PI;
const float MAX_RADIUS = 200.0;
const float MAX_SIGHT_DISTANCE = 750.0;

float get_visibility_modifier(vec2 frag_coord) {
	// Returns visibility of a frag based on distance from player and mouse position
	vec2 player_to_mouse = mouse_pos - player_pos;
	vec2 player_to_frag = frag_coord.xy - player_pos;

	// This gets the the dot product of the unit vectors of vectors player_to_mouse and player_to_frag
	// product ranges from {-1, 1} where -1 is pi and 1 is 0.
	// We then determine if a fragment is within the player's look direction if it's
	// between max_sight_angle and 0.
	float product = dot(normalize(player_to_mouse), normalize(player_to_frag));
	// Makes it so we're dealing with a range of {0, 1} where 0 is 0 and 1 represents pi.
	float angle = (product * -1.0 + 1.0) / 2.0;
	bool in_look_direction = angle <= MAX_SIGHT_ANGLE;

	float radius_dropoff = length(player_to_frag) / MAX_RADIUS;
	float radius_visibility = 1.0 - radius_dropoff;

	float sight_dropoff = length(player_to_frag) / MAX_SIGHT_DISTANCE;
	float sight_angular_dropoff = angle / MAX_SIGHT_ANGLE;
	float sight_visibility = 1.0 - sight_dropoff - sight_angular_dropoff;

	if (in_look_direction && sight_visibility >= radius_visibility) {
		return sight_visibility;
	} else {
		return radius_visibility;
	}
}

void vertex() {
	if (in_game) {
		// Creates underwater effect
		VERTEX.x += sin(VERTEX.y + TIME * 2.0) * 3.0;
	}
}

void fragment() {
	// COLOR.a > 0.0001 makes it so we don't modify transparent pixels
	if (in_game && COLOR.a > 0.0001) {
		// modifies rgba values by uniforms
		COLOR.rgb = vec3(COLOR.r * red_factor, COLOR.g * green_factor, COLOR.b * blue_factor);
		COLOR.a = alpha;

		// makes it so mob fades out as they get farther away from player_pos / gets out of player's sight
		float visibility = get_visibility_modifier(FRAGCOORD.xy);
		COLOR = vec4(COLOR.rgb * visibility, COLOR.a);
	}
}
