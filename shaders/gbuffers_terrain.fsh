#version 120

#include "/lib/common.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;
uniform vec3 sunPosition;
uniform vec3 shadowLightPosition;
uniform vec3 upPosition;
uniform vec3 cameraPosition;
uniform float sunAngle;
uniform float rainStrength;
uniform float shadowMapResolution;

varying vec2 texCoord;
varying vec2 lmCoord;
varying vec4 vColor;
varying vec3 worldNormal;
varying vec3 worldPos;
varying vec4 shadowCoord;
varying float blockId;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * vColor;
    if (albedo.a < 0.05) discard;

    vec3 N = normalize(worldNormal);
    vec3 L = normalize(shadowLightPosition);
    float NdotL = max(dot(N, L), 0.0);

    // ---- Schatten ----
    float texelSize = 1.0 / shadowMapResolution;
    float shadow = 1.0;
    if (shadowCoord.z >= 0.0 && shadowCoord.z <= 1.0) {
        shadow = sampleShadowPCF(shadowtex1, shadowCoord.xyz, texelSize);
        // Selbstverschattung an flachen Winkeln abmildern
        shadow = mix(shadow, 1.0, clamp(1.0 - NdotL * 2.0, 0.0, 1.0) * 0.15);
    }

    vec3 sunColor = sunlightColor(sunAngle);
    float sunI = sunlightIntensity(sunAngle) * (1.0 - rainStrength * 0.6);

    // ---- Minecraft-Lightmap (Block-/Himmelslicht aus lmCoord) ----
    vec3 lm = texture2D(lightmap, lmCoord).rgb;

    // ---- Direktes Sonnenlicht ----
    vec3 direct = sunColor * sunI * NdotL * shadow;

    // ---- Ambient (Himmelslicht + minimaler Sockel, damit nichts komplett schwarz wird) ----
    vec3 ambient = lm * (0.35 + 0.15 * dayFactor(sunAngle));

    vec3 lighting = ambient + direct * 0.85;

    // ---- Dezenter Specular-Highlight (PBR-lite) fuer nasse/glatte Oberflaechen ----
    vec3 viewDir = normalize(cameraPosition - worldPos);
    vec3 halfVec = normalize(L + viewDir);
    float spec = pow(max(dot(N, halfVec), 0.0), 48.0);
    float wetBoost = rainStrength * 0.6;
    vec3 specular = sunColor * spec * shadow * (0.05 + wetBoost);

    vec3 color = albedo.rgb * lighting + specular;

    gl_FragData[0] = vec4(color, albedo.a);
}
