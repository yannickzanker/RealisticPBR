#version 120

#include "/lib/common.glsl"

attribute vec3 mc_Entity;
attribute vec3 at_midBlock;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;

varying vec2 texCoord;
varying vec2 lmCoord;
varying vec4 vColor;
varying vec3 worldNormal;
varying vec3 worldPos;
varying vec4 shadowCoord;
varying float blockId;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor   = gl_Color;
    blockId  = mc_Entity.x;

    vec4 position = gl_Vertex;

    // Weltposition (fuer Wind-Phase, unabhaengig von Chunk-Offset)
    vec3 absoluteWorldPos = position.xyz + at_midBlock.xyz / 64.0 + cameraPosition;

    // ---- Wind-Animation fuer Gras/Blumen/Reben (10001) und Laub (10002) ----
    if (blockId == 10001.0 || blockId == 10002.0) {
        float isTop = clamp(at_midBlock.y, 0.0, 1.0); // Wind wirkt nur auf obere Vertices
        float windPhase = frameTimeCounter * 1.6 + absoluteWorldPos.x * 0.9 + absoluteWorldPos.z * 0.9;
        float sway = sin(windPhase) * 0.045 + sin(windPhase * 2.3 + 1.0) * 0.02;
        float strength = (blockId == 10002.0) ? 0.5 : 1.0; // Laub wehet dezenter
        position.x += sway * strength * (blockId == 10001.0 ? isTop : 1.0);
        position.z += cos(windPhase * 0.8) * 0.03 * strength;
    }

    // ---- Wasseroberflaechen-Wellen (10010) ----
    if (blockId == 10010.0) {
        float wavePhase = frameTimeCounter * 1.1 + absoluteWorldPos.x * 0.6 + absoluteWorldPos.z * 0.6;
        position.y += sin(wavePhase) * 0.03;
    }

    vec4 viewPos = gl_ModelViewMatrix * position;
    gl_Position = gl_ProjectionMatrix * viewPos;

    // Weltraum-Normale (fuer Beleuchtung im Fragment-Shader)
    worldNormal = normalize(mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal);
    worldPos = (gbufferModelViewInverse * viewPos).xyz;

    // ---- Shadow-Space-Koordinate berechnen ----
    vec4 shadowViewPos = shadowModelView * (gbufferModelViewInverse * viewPos);
    shadowCoord = shadowProjection * shadowViewPos;
    // Distortion mildern (mehr Aufloesung nahe der Kamera) - leichte Standardverzerrung
    float distB = length(shadowCoord.xy);
    float distortFactor = distB * 0.9 + 0.1;
    shadowCoord.xy /= distortFactor;
    shadowCoord = shadowCoord * 0.5 + 0.5;
}
