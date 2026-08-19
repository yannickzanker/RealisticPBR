#version 120

#include "/lib/common.glsl"

uniform sampler2D colortex0;

varying vec2 texCoord;

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    // Filmisches Tonemapping (HDR -> LDR)
    color = tonemapACES(color * 1.15);

    // Gamma-Korrektur
    color = pow(color, vec3(1.0 / 2.2));

    // Dezente Vignette
    vec2 uv = texCoord - 0.5;
    float vig = 1.0 - dot(uv, uv) * 0.35;
    color *= vig;

    gl_FragData[0] = vec4(color, 1.0);
}
