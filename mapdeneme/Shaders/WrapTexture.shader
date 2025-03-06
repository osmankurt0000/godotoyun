shader_type canvas_item;

uniform sampler2D emission_texture;
uniform float speed = 0.0;

void fragment(){
    vec2 newuv = UV;
	
    newuv.x -= TIME * speed;

    vec4 c = texture(emission_texture, newuv);
    COLOR = c;
}