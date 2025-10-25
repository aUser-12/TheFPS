shader_type canvas_item;

uniform float time : hint_range(0.0, 1.0);
uniform float pieces = 20.0;
uniform float intensity = 200.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    vec2 cell = floor(uv * pieces);
    float r = rand(cell);
    //spread out frags
    uv += (vec2(rand(cell + 1.0), rand(cell + 2.0)) - 0.5) * time * (intensity / pieces);
    vec4 col = texture(TEXTURE, uv);
    //fade out
    col.a *= (1.0 - time);
    COLOR = col;
}
