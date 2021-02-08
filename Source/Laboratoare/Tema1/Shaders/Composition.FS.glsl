#version 430

layout(location = 0) in vec2 texture_coord;

uniform sampler2D texture_position;
uniform sampler2D texture_normal;
uniform sampler2D texture_color;
uniform sampler2D texture_depth;
uniform sampler2D texture_light;
//uniform sampler2D texture_cubemap_color;
//uniform sampler2D texture_cubemap_depth;

uniform int output_type;

layout(location = 0) out vec4 out_color;

float near = 0.1; 
float far  = 60.0; 
  
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0; // back to NDC 
    return (2.0 * near * far) / (far + near - z * (far - near));	
}

vec4 blur(int blurRadius)
{
	vec2 texelSize = 1.0f / vec2(640,640);
	vec4 sum = vec4(0);
	for(int i = -blurRadius; i <= blurRadius; i++)
	{
		for(int j = -blurRadius; j <= blurRadius; j++)
		{
			sum += texture(texture_color, texture_coord + vec2(i, j) * texelSize);
		}
	}
		
	float samples = pow((2 * blurRadius + 1), 2);
	return sum / samples;
}

vec3 depth()
{
	float t2 = pow(texture(texture_depth, texture_coord).x , 256);
	return vec3(t2, t2, t2);
}

vec3 color()
{
	return texture(texture_color, texture_coord).xyz;
}


vec3 world_normal()
{
	return texture(texture_normal, texture_coord).xyz;
}

vec3 world_position()
{
	return texture(texture_position, texture_coord).xyz;
}

vec3 light_accumulation()
{
	return texture(texture_light, texture_coord).xyz;
}

void main()
{
	switch (output_type)
	{
		case 1:
			out_color = vec4(color(), 1);
			break;

		case 2:
			out_color = vec4(depth(), 1);
			break;

		case 3:
			out_color = vec4(world_position(), 1);
			break;

		case 4:
			out_color = vec4(world_normal(), 1);
			break;

		case 5:
			out_color = vec4(light_accumulation(), 1);
			break;

		case 6:
			out_color = vec4(light_accumulation() * color(), 1);
			break;

		default:
			//out_color = vec4(color(), 1);
			float d = LinearizeDepth(depth().x);
			if(depth().x == 1)
				out_color = vec4(blur(2).xyz, 1);
			else
				if( d < 0.66f)
					out_color = vec4(light_accumulation() * color(), 1);
				else
					if (d >= 0.9f)
						out_color = vec4(light_accumulation() * blur(2).xyz, 1);
					else
						out_color = vec4(light_accumulation() * color(), 1) * (1-d) +  vec4(light_accumulation() * blur(2).xyz, 1) * d ;
						//out_color = vec4(d,d,d,1);
				
	}
}