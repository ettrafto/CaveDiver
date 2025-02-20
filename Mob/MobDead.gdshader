// code from https://godotshaders.com/shader/parametric-linear-rgb-dimmer/

shader_type canvas_item;

// Parameters to control the damping factors for red, green, and blue channels
// hint_range() restricts values to a range (with min/max/step).
uniform float red_factor : hint_range(0.0, 1.0) = 1.0;
uniform float green_factor : hint_range(0.0, 1.0) = 1.0;
uniform float blue_factor : hint_range(0.0, 1.0) = 1.0;

// Parameter to control the alpha factor
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	if (COLOR.a > 0.0001) {
		// Reduce the red, green, and blue channels by their respective factors
		COLOR.rgb = vec3(COLOR.r * red_factor, COLOR.g * green_factor, COLOR.b * blue_factor);
		// Adjust the alpha channel
		COLOR.a = alpha;
	}
}
