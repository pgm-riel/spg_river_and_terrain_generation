#version 430

layout(location = 0) in vec2 texture_coord;
layout(location = 1) in vec3 world_position;

uniform sampler2D texture_1;

layout(location = 0) out vec4 out_world_position;
layout(location = 1) out vec4 out_world_normal;
layout(location = 2) out vec4 out_color;


void main()
{

	out_world_position = vec4(world_position, 1);
	out_world_normal = vec4(vec3(0,1,0), 0);
	vec4 color = texture(texture_1, texture_coord);

	out_color = vec4(color.xyz, 1);
}