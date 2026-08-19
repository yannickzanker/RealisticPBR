#version 120

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec2 texCoord;
varying vec2 lmCoord;
varying vec4 vColor;
varying vec3 viewNormal;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * vColor;
    if (albedo.a < 0.05) discard;

    vec3 lm = texture2D(lightmap, lmCoord).rgb;
    float facing = clamp(dot(normalize(viewNormal), vec3(0.0, 0.0, 1.0)) * 0.5 + 0.5, 0.3, 1.0);

    gl_FragData[0] = vec4(albedo.rgb * lm * facing * 1.6, albedo.a);
}
