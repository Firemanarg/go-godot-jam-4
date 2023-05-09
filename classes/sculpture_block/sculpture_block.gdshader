shader_type canvas_item;

uniform float columns = 16.0;
uniform float rows = 16.0;
uniform float influence : hint_range(0.0, 1.0, 0.1) = 0.2;

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

void fragment()
{
	COLOR = texture_shader(SCREEN_UV, COLOR);
}
