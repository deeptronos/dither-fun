shader_type spatial;
//render_mode diffuse_toon, specular_toon;
uniform sampler2D noise;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
//uniform sampler2D normalmap;
uniform float bias;
uniform float height_scale = 0.5;

varying vec2 tex_position;

const mat4 bayerMatrix4x4 = mat4(
    vec4(0.0,  8.0,  2.0, 10.0),
    vec4(12.0, 4.0,  14.0, 6.0),
    vec4(3.0,  11.0, 1.0, 9.0),
    vec4(15.0, 7.0,  13.0, 5.0)
) / 16.0;

float get_bayer_threshold(vec2 c){
	ivec2 bayer_coord = ivec2(c.xy) % 4;
	float threshold = bayerMatrix4x4[bayer_coord.x][bayer_coord.y];
	return threshold;
}

float random(vec2 c) {
	//vec4 t = texture(noise, c.xy) * vec4(43758.5453);
	//return fract(sin(dot(c.xy, texture(noise, c/10.0).xy)));
	return fract(sin(dot(c.xy, vec2(12.9898, 78.233))) * 43758.5453);
	//return fract(sin(dot(c.xy,vec2(t.x, t.y))) * 1.0);
}

vec3 orderedDither(vec2 uv, float lum){
	vec3 color = vec3(0.0);
	float threshold = get_bayer_threshold(uv);
	if(lum < threshold + bias){
		color = vec3(0.0);
	}
	else
	{
		color=vec3(1.0);
	}
	return color;
}

void vertex() {

}


void fragment() {
	// Called for every pixel the material is visible on.
	
	//vec4 cc = textureLod(screen_texture, SCREEN_UV, 0.0);
	vec4 cc = COLOR;
	float lum = dot(vec3(0.2126, 0.7152, 0.0722), cc.rgb);
	//float lum = max(cc.r, max(cc.g, cc.b)); // innaccurate!!
	cc.rgb = orderedDither(FRAGCOORD.xy, lum);
	
	//ALBEDO=cc.rgb;
	ALPHA=float((cc.r + cc.g + cc.b)/3.0 ); // Dither upon Alpha
	
	//float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
    //vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    //vec3 pixel_position = upos.xyz / upos.w;
	//ALPHA=upos.a;
}



//void light() {
	//
	//// Called for every pixel for every light affecting the material.
	//// Uncomment to replace the default light processing function with this one.
	//vec4 cc = textureLod(screen_texture, SCREEN_UV, 0.0);
	//float lum = dot(vec3(0.2126, 0.7152, 0.0722), cc.rgb);
	////float lum = max(cc.r, max(cc.g, cc.b)); // innaccurate!!
	//cc.rgb = orderedDither(UV, lum);
	//SPECULAR_LIGHT += (5.0-cc.rgb);
//}
