#version 120

#include "/lib/common.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2DShadow shadowtex1;
uniform vec3 shadowLightPosition;
uniform float sunAngle;
uniform float rainStrength;
uniform float shadowMapResolution;
uniform vec4 entityColor;

varying vec2 texCoord;
varying vec2 lmCoord;
varying vec4 vColor;
varying vec3 worldNormal;
varying vec3 worldPos;
varying vec4 shadowCoord;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * vColor;
    albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
    if (albedo.a < 0.05) discard;

    vec3 N = normalize(worldNormal);
    vec3 L = normalize(shadowLightPosition);
    float NdotL = max(dot(N, L), 0.0);

    float texelSize = 1.0 / shadowMapResolution;
    float shadow = 1.0;
    if (shadowCoord.z >= 0.0 && shadowCoord.z <= 1.0) {
        shadow = sampleShadowPCF(shadowtex1, shadowCoord.xyz, texelSize);
    }

    vec3 sunColor = sunlightColor(sunAngle);
    float sunI = sunlightIntensity(sunAngle) * (1.0 - rainStrength * 0.6);
    vec3 lm = texture2D(lightmap, lmCoord).rgb;

    vec3 direct = sunColor * sunI * NdotL * shadow;
    vec3 ambient = lm * (0.35 + 0.15 * dayFactor(sunAngle));

    gl_FragData[0] = vec4(albedo.rgb * (ambient + direct * 0.85), albedo.a);
}
