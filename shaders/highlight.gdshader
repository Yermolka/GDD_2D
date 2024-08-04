shader_type spatial;

uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float shine_speed : hint_range(0.1, 10) = 1.0;
uniform float smoothness : hint_range(0.1, 1.0) = 0.5;

void vertex() {
    // No changes to vertex function for this effect
}

void fragment() {
    float shine = abs(sin(TIME * shine_speed));
    float smooth_shine = smoothstep(0.0, smoothness, shine);
    ALBEDO = mix(ALBEDO, shine_color.rgb, smooth_shine);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
