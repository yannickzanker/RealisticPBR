#version 120

varying vec2 texCoord;
varying vec4 vColor;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vColor = gl_Color;

    vec4 pos = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;

    // gleiche Distortion wie im shadowCoord-Berechnung der gbuffers-Shader,
    // damit die Aufloesung nahe der Kamera hoeher ist
    float distB = length(pos.xy);
    float distortFactor = distB * 0.9 + 0.1;
    pos.xy /= distortFactor;

    gl_Position = pos;
}
