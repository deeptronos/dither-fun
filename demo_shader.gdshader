shader_type spatial;
render_mode specular_toon;
uniform sampler2D noise;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
//uniform sampler2D normalmap;
uniform float height_scale = 0.5;

varying vec2 tex_position;

float random(vec2 c) {
	//return fract(sin(dot(c.xy, texture(noise, c/10.0).xy)));
	return fract(sin(dot(c.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 whiteNoiseDither(vec2 uv, float lum) {
	vec3 color = vec3(0.0);
	
	if(lum < random(uv)){
		color = vec3(0.0);
	} else {
		color = vec3(1.0);
	}
	return color;
}

void vertex() {

}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec4 cc = textureLod(screen_texture, SCREEN_UV, 0.0);
	float lum = dot(vec3(0.2126, 0.7152, 0.0722), cc.rgb);
	cc.rgb = whiteNoiseDither(UV, lum);
	ALBEDO=cc.rgb;
}



//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
