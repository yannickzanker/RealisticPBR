#version 120

uniform sampler2D colortex0;

varying vec2 texCoord;

/* DRAWBUFFERS:1 */

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    float threshold = 1.0;
    vec3 bright = color * smoothstep(threshold, threshold + 1.0, brightness);
    gl_FragData[0] = vec4(bright, 1.0);
}
