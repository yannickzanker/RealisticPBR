#version 120

uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

varying vec2 texCoord;

/* DRAWBUFFERS:2 */

void main() {
    vec2 texel = 1.0 / vec2(viewWidth, viewHeight);
    vec3 result = vec3(0.0);
    float weights[5] = float[5](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

    result += texture2D(colortex1, texCoord).rgb * weights[0];
    for (int i = 1; i < 5; i++) {
        vec2 off = vec2(float(i), 0.0) * texel;
        result += texture2D(colortex1, texCoord + off).rgb * weights[i];
        result += texture2D(colortex1, texCoord - off).rgb * weights[i];
    }
    for (int i = 1; i < 5; i++) {
        vec2 off = vec2(0.0, float(i)) * texel;
        result += texture2D(colortex1, texCoord + off).rgb * weights[i] * 0.6;
        result += texture2D(colortex1, texCoord - off).rgb * weights[i] * 0.6;
    }

    gl_FragData[0] = vec4(result, 1.0);
}
