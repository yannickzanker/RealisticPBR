#version 120

uniform sampler2D colortex0;
uniform sampler2D colortex2;

#define BLOOM_STRENGTH 0.3

varying vec2 texCoord;

/* DRAWBUFFERS:0 */

void main() {
    vec3 base = texture2D(colortex0, texCoord).rgb;
    vec3 bloom = texture2D(colortex2, texCoord).rgb;
    vec3 result = base + bloom * BLOOM_STRENGTH;
    gl_FragData[0] = vec4(result, 1.0);
}
