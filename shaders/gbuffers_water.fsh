#version 120

#include "/lib/common.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;
uniform sampler2DShadow shadowtex1;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform float sunAngle;
uniform float rainStrength;
uniform float shadowMapResolution;

#define WATER_REFLECTION true

varying vec2 texCoord;
varying vec2 lmCoord;
varying vec4 vColor;
varying vec3 worldNormal;
varying vec3 worldPos;
varying vec4 shadowCoord;
varying float isWater;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * vColor;
    if (albedo.a < 0.02) discard;

    vec3 N = normalize(worldNormal);
    vec3 L = normalize(shadowLightPosition);
    float NdotL = max(dot(N, L), 0.0);

    float texelSize = 1.0 / shadowMapResolution;
    float shadow = 1.0;
    if (shadowCoord.z >= 0.0 && shadowCoord.z <= 1.0) {
        shadow = sampleShadowPCF(shadowtex1, shadowCoord.xyz, texelSize);
    }

    vec3 sunColor = sunlightColor(sunAngle);
    float sunI = sunlightIntensity(sunAngle) * (1.0 - rainStrength * 0.4);
    vec3 lm = texture2D(lightmap, lmCoord).rgb;

    vec3 viewDir = normalize(cameraPosition - worldPos);
    vec3 color = albedo.rgb;
    float alpha = albedo.a;

    if (isWater > 0.5) {
        // ---- Fresnel-basierte Himmelsreflexion ----
        float cosTheta = clamp(dot(N, viewDir), 0.0, 1.0);
        float fresnel = fresnelSchlick(cosTheta, 0.02);

#if WATER_REFLECTION
        vec3 reflectDir = reflect(-viewDir, N);
        vec3 skyRefl = approxSkyColor(reflectDir, sunColor, sunAngle);
        color = mix(albedo.rgb * (lm * 0.5 + 0.15), skyRefl, fresnel * 0.85);
#endif

        // Sonnen-Glanzpunkt auf dem Wasser
        vec3 halfVec = normalize(L + viewDir);
        float spec = pow(max(dot(N, halfVec), 0.0), 120.0);
        color += sunColor * spec * shadow * 1.4;

        alpha = clamp(alpha + fresnel * 0.4, 0.0, 0.92);
        color *= (0.55 + 0.45 * NdotL * shadow) ;
    } else {
        vec3 direct = sunColor * sunI * NdotL * shadow;
        vec3 ambient = lm * 0.4;
        color = albedo.rgb * (ambient + direct * 0.85);
    }

    gl_FragData[0] = vec4(color, alpha);
}
