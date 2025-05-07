shader_type canvas_item;

// Prevents shader from being previewed out of game
global uniform bool in_game;
global uniform vec2 player_pos;
global uniform vec2 mouse_pos;

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
		//COLOR.r += sin(TIME);
	}
}

void fragment() {
	if (in_game) {
		float visibility = get_visibility_modifier(FRAGCOORD.xy);
		COLOR = vec4(COLOR.rgb * visibility, COLOR.a);
	}
}
