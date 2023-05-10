shader_type canvas_item;

uniform float columns = 16.0;
uniform float rows = 16.0;
uniform float influence : hint_range(0.0, 1.0, 0.1) = 0.2;
uniform vec4 line_color : source_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;
uniform float blend_influence : hint_range(0.0, 1.0, 0.05) = 0.5;

vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;  

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}

	return minimum_dist;
}

vec4 texture_shader(vec2 uv, vec4 color)
{
	float worley = worley(uv);
	vec4 result = vec4(vec3(worley), 0.0);
	vec4 output = mix(color, result, influence);

	return (output);
}

vec4 outline_shader(vec2 texture_pixel_size, sampler2D _texture, vec2 uv)
{
	vec2 size = texture_pixel_size * line_thickness;
	
	float outline = texture(_texture, uv + vec2(-size.x, 0)).a;
	outline += texture(_texture, uv + vec2(0, size.y)).a;
	outline += texture(_texture, uv + vec2(size.x, 0)).a;
	outline += texture(_texture, uv + vec2(0, -size.y)).a;
	outline += texture(_texture, uv + vec2(-size.x, size.y)).a;
	outline += texture(_texture, uv + vec2(-size.x, size.y * 0.5)).a;
	outline += texture(_texture, uv + vec2(size.x, size.y)).a;
	outline += texture(_texture, uv + vec2(size.x, size.y * 0.5)).a;
	outline += texture(_texture, uv + vec2(-size.x, -size.y)).a;
	outline += texture(_texture, uv + vec2(-size.x, -size.y * 0.5)).a;
	outline += texture(_texture, uv + vec2(size.x, -size.y)).a;
	outline += texture(_texture, uv + vec2(size.x, -size.y * 0.5)).a;
	outline = min(outline, 1.0);
	if (outline > 0.0)
	{
		vec4 color = texture(_texture, uv);
		vec4 output = mix(color, line_color, outline - color.a);
		return (output);
	}
	return (vec4(0.0));
}

void fragment()
{
	vec4 texture_output = texture_shader(SCREEN_UV, COLOR);
	vec4 outline_output = outline_shader(TEXTURE_PIXEL_SIZE, TEXTURE, UV);
	COLOR = mix(texture_output, outline_output, blend_influence);
	if (COLOR.a > 0.0)
		COLOR.a = 1.0;
}
