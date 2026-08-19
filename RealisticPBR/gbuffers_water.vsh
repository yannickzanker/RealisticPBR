#version 120

#include "/lib/common.glsl"

attribute vec3 mc_Entity;

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
varying float isWater;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor   = gl_Color;
    isWater  = (mc_Entity.x == 10010.0) ? 1.0 : 0.0;

    vec4 position = gl_Vertex;
    vec3 absoluteWorldPos = position.xyz + cameraPosition;

    if (isWater > 0.5) {
        float p = frameTimeCounter * 1.1 + absoluteWorldPos.x * 0.6 + absoluteWorldPos.z * 0.6;
        position.y += sin(p) * 0.03;
    }

    vec4 viewPos = gl_ModelViewMatrix * position;
    gl_Position = gl_ProjectionMatrix * viewPos;

    worldNormal = normalize(mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal);
    worldPos = (gbufferModelViewInverse * viewPos).xyz;

    vec4 shadowViewPos = shadowModelView * (gbufferModelViewInverse * viewPos);
    shadowCoord = shadowProjection * shadowViewPos;
    float distB = length(shadowCoord.xy);
    float distortFactor = distB * 0.9 + 0.1;
    shadowCoord.xy /= distortFactor;
    shadowCoord = shadowCoord * 0.5 + 0.5;
}
