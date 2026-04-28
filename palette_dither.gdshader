shader_type spatial;
//render_mode diffuse_toon, specular_toon;
uniform sampler2D noise;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
//uniform sampler2D normalmap;
//uniform float bias;
uniform float colorNum;
uniform float pixelSize;
//uniform float height_scale = 0.5;

varying vec2 tex_position;

const mat4 bayerMatrix4x4 = mat4(
    vec4(0.0,  8.0,  2.0, 10.0),
    vec4(12.0, 4.0,  14.0, 6.0),
    vec4(3.0,  11.0, 1.0, 9.0),
    vec4(15.0, 7.0,  13.0, 5.0)
) / 16.0;

const float bayerMatrix8x8[64] = float[64](
    0.0/ 64.0, 48.0/ 64.0, 12.0/ 64.0, 60.0/ 64.0,  3.0/ 64.0, 51.0/ 64.0, 15.0/ 64.0, 63.0/ 64.0,
	32.0/ 64.0, 16.0/ 64.0, 44.0/ 64.0, 28.0/ 64.0, 35.0/ 64.0, 19.0/ 64.0, 47.0/ 64.0, 31.0/ 64.0,
    8.0/ 64.0, 56.0/ 64.0,  4.0/ 64.0, 52.0/ 64.0, 11.0/ 64.0, 59.0/ 64.0,  7.0/ 64.0, 55.0/ 64.0,
	40.0/ 64.0, 24.0/ 64.0, 36.0/ 64.0, 20.0/ 64.0, 43.0/ 64.0, 27.0/ 64.0, 39.0/ 64.0, 23.0/ 64.0,
    2.0/ 64.0, 50.0/ 64.0, 14.0/ 64.0, 62.0/ 64.0,  1.0/ 64.0, 49.0/ 64.0, 13.0/ 64.0, 61.0/ 64.0,
	34.0/ 64.0, 18.0/ 64.0, 46.0/ 64.0, 30.0/ 64.0, 33.0/ 64.0, 17.0/ 64.0, 45.0/ 64.0, 29.0/ 64.0,
	10.0/ 64.0, 58.0/ 64.0,  6.0/ 64.0, 54.0/ 64.0,  9.0/ 64.0, 57.0/ 64.0,  5.0/ 64.0, 53.0/ 64.0,
	42.0/ 64.0, 26.0/ 64.0, 38.0/ 64.0, 22.0/ 64.0, 41.0/ 64.0, 25.0/ 64.0, 37.0/ 64.0, 21.0 / 64.0
);



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

//vec3 orderedDither(vec2 uv, float lum){
	//vec3 color = vec3(0.0);
	//float threshold = get_bayer_threshold(uv);
	//if(lum < threshold + bias){
		//color = vec3(0.0);
	//}
	//else
	//{
		//color=vec3(1.0);
	//}
	//return color;
//}

vec3 dither(vec2 uv,vec3 color, vec2 screen_size){
	int x = int(uv.x * screen_size.x) % 8;
	int y = int(uv.y * screen_size.y) % 8;
	float threshold = bayerMatrix8x8[y * 8 + x] - 0.88;
	
	color.rgb += threshold;
	color.r = floor(color.r * (colorNum - 1.0) + 0.5) / (colorNum - 1.0);
	color.g = floor(color.g * (colorNum - 1.0) + 0.5) / (colorNum - 1.0);
  	color.b = floor(color.b * (colorNum - 1.0) + 0.5) / (colorNum - 1.0);
	return color;
}


void vertex() {

}


void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 normalizedPixelSize = pixelSize / VIEWPORT_SIZE;
	vec2 uvPixel = normalizedPixelSize * floor(FRAGCOORD.xy / normalizedPixelSize);
	vec4 cc = COLOR;
	cc.rgb = dither(uvPixel, cc.rgb,VIEWPORT_SIZE);
	ALBEDO=cc.rgb;
		
	//vec4 cc = textureLod(screen_texture, SCREEN_UV, 0.0);
	//vec4 cc = COLOR;
	//float lum = dot(vec3(0.2126, 0.7152, 0.0722), cc.rgb);
	////float lum = max(cc.r, max(cc.g, cc.b)); // innaccurate!!
	//cc.rgb = dither(FRAGCOORD.xy, lum, VIEWPORT_SIZE);
	//cc.a = float((cc.r + cc.g + cc.b) / 3.0);
	//ALBEDO=cc.rgb;
	////ALPHA=cc.a;
	////ALPHA_SCISSOR_THRESHOLD = 0.0;
	//ALPHA_HASH_SCALE = 1.0; // For some reason, if we don't set this, backfaces of the model are transparent? TODO wtf
	////ALPHA=a;
	//ALPHA=float((cc.r + cc.g + cc.b)/3.0 ); // Dither upon Alpha
	
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
