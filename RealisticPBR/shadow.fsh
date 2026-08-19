#version 120

uniform sampler2D texture;

varying vec2 texCoord;
varying vec4 vColor;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * vColor;
    if (albedo.a < 0.5) discard;
    gl_FragData[0] = vec4(1.0);
}
