shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);

void fragment()
{
	if (COLOR.a > 0.0)
		COLOR = color;
}
