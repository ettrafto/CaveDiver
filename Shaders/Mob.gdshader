shader_type canvas_item;

// Prevents shader from being previewed out of game
global uniform bool in_game = false;

global uniform vec2 player_pos = vec2(0, 0);

uniform vec4 general_light_info[100];
uniform vec3 general_light_colors[100];
uniform int light_illumination_masks[100];
uniform int num_point_lights = 0;

uniform vec3 directional_light_info[100];
uniform int num_directional_lights = 0;

// hint_range() restricts values to a range (with min/max/step).
instance uniform float red_factor : hint_range(0.0, 1.0) = 1.0;
instance uniform float green_factor : hint_range(0.0, 1.0) = 1.0;
instance uniform float blue_factor : hint_range(0.0, 1.0) = 1.0;
instance uniform float alpha : hint_range(0.0, 1.0) = 1.0;

instance uniform int illumination_mask = 1;
instance uniform bool soft_illumination_cutoff = false;

bool within_shadow(vec2 frag_position) {
	const int step_limit = 600;

	bool in_shadow = false;
	vec2 curr_pos = frag_position;
	float distance_from_player = distance(curr_pos, player_pos);
	for (int i = 0; i < step_limit; i++) {
		float sdf = texture_sdf(curr_pos);
		if (sdf <= 0.0) {
			in_shadow = true;
			break;
		}
		vec2 step_distance = vec2(1, 1) / distance_from_player;
		curr_pos = mix(curr_pos, player_pos, step_distance);
		distance_from_player = distance(curr_pos, player_pos);
	}

	return in_shadow;
}

bool[4] get_mask_as_array(int mask) {
	bool mask_arr[4];

	mask_arr[0] = bool(mask & 1);
	mask_arr[1] = bool(mask & 2);
	mask_arr[2] = bool(mask & 4);
	mask_arr[3] = bool(mask & 8);

	return mask_arr;
}

vec4 get_point_light_influence(vec2 frag_position) {
	float greatest_brightness = 0.0;
	vec3 color_influence = vec3(0.0, 0.0, 0.0);
	bool illumination_mask_arr[4] = get_mask_as_array(illumination_mask);

	for (int i = 0; i < num_point_lights; i++) {
		bool[4] light_illumination_mask_arr = get_mask_as_array(light_illumination_masks[i]);

		bool illuminated = false;
		for (int i = 0; i < 4; i++) {
			if (illumination_mask_arr[i] && light_illumination_mask_arr[i]) {
				illuminated = true;
				break;
			}
		}

		if (!illuminated)
			continue;

		vec4 light_info = general_light_info[i];
		vec2 light_position = light_info.xy;
		float light_radius = light_info.z;
		float light_intensity = light_info.a;

		vec3 light_color = general_light_colors[i];

		float frag_to_light = distance(light_position, frag_position);
		float radius_dropoff = length(frag_to_light) / (light_radius / light_intensity);
		float light_brightness = light_intensity - radius_dropoff;

		if (light_brightness > 0.0) {
			color_influence += light_color * light_brightness;
			if (light_brightness > greatest_brightness)
				greatest_brightness = light_brightness;
		}
	}

	return vec4(color_influence.r, color_influence.g, color_influence.b, greatest_brightness);
}

vec4 get_directional_light_influence(vec2 frag_position) {
	float greatest_brightness = 0.0;
	vec3 color_influence = vec3(0, 0, 0);

	for (int i = num_point_lights; i < num_point_lights + num_directional_lights; i++) {
		vec4 light_info = general_light_info[i];
		vec2 light_position = light_info.xy;
		float light_distance = light_info.z;
		float light_intensity = light_info.a;

		vec3 light_color = general_light_colors[i];

		vec3 directional_info = directional_light_info[i - num_point_lights];
		vec2 direction = directional_info.xy;
		float max_angle = radians(directional_info.z)/PI;

		vec2 light_to_frag = frag_position - light_position;

		// This gets the the dot product of the unit vectors
		// product ranges from {-1, 1} where -1 is pi and 1 is 0.
		// We then determine if a fragment is within the light's look direction if it's
		// between max_angle and 0.
		float product = dot(normalize(light_to_frag), direction);
		// Makes it so we're dealing with a range of {0, 1} where 0 is 0 and 1 represents pi.
		float angle = (product * -1.0 + 1.0) / 2.0;
		bool in_look_direction = angle <= max_angle;

		float distance_dropoff = length(light_to_frag) / (light_distance / light_intensity);
		float angular_dropoff = angle / (max_angle / light_intensity);
		float light_brightness = light_intensity - distance_dropoff - angular_dropoff;

		if (in_look_direction && light_brightness > 0.0) {
			color_influence += light_color * light_brightness;
			if (light_brightness > greatest_brightness)
				greatest_brightness = light_brightness;
		}
	}

	return vec4(color_influence, greatest_brightness);
}

vec4 get_light_influence(vec2 frag_position) {
	vec4 point_light_influence = get_point_light_influence(frag_position);
	vec4 directional_light_influence = get_directional_light_influence(frag_position);
	float greatest_brightness = max(point_light_influence.a, directional_light_influence.a);
	return vec4(point_light_influence.xyz + directional_light_influence.xyz, greatest_brightness);
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
