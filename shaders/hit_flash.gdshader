shader_type canvas_item;

uniform float hitflash_amount : hint_range (0.0, 1.0) = 0.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	COLOR.rgb = mix(original_color.rgb, vec3(3, 3, 3), hitflash_amount);
	COLOR.a = original_color.a;
}
