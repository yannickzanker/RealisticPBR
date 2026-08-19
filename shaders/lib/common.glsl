// ============================================================
//  RealisticPBR - lib/common.glsl
//  Gemeinsame Hilfsfunktionen fuer alle Shader-Stages
// ============================================================

#ifndef COMMON_GLSL
#define COMMON_GLSL

const float PI = 3.14159265359;

// ---- Sonnenwinkel -> weiche Tag/Nacht/Daemmerungs-Mischung ----
// sunAngle: 0.0 = Mittag, 0.25 = Sonnenuntergang, 0.5 = Mitternacht, 0.75 = Sonnenaufgang
float dayFactor(float sunAngle) {
    float a = abs(fract(sunAngle + 0.5) - 0.5) * 2.0; // 0 bei Mittag, 1 bei Mitternacht
    return clamp(1.0 - a * 1.15, 0.0, 1.0);
}

// ---- Warmes Sonnenlicht am Tag, kuehles blaues Mondlicht in der Nacht,
//      orange Kante bei Sonnenauf-/-untergang ----
vec3 sunlightColor(float sunAngle) {
    float day   = dayFactor(sunAngle);
    float dusk  = pow(1.0 - abs(day - 0.5) * 2.0, 4.0) * step(0.15, day) * step(day, 0.85);

    vec3 dayCol   = vec3(1.05, 1.00, 0.92);
    vec3 nightCol = vec3(0.20, 0.28, 0.45) * 0.5;
    vec3 duskCol  = vec3(1.30, 0.55, 0.20);

    vec3 col = mix(nightCol, dayCol, day);
    col = mix(col, duskCol, dusk * 0.55);
    return col;
}

float sunlightIntensity(float sunAngle) {
    float day = dayFactor(sunAngle);
    return mix(0.06, 1.0, day);
}

// ---- Fresnel (Schlick-Approximation) fuer Wasser/Glas-Reflexionen ----
float fresnelSchlick(float cosTheta, float f0) {
    return f0 + (1.0 - f0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

// ---- Einfache Himmelsfarbe fuer Fake-Reflexionen (kein echtes SSR) ----
vec3 approxSkyColor(vec3 viewDir, vec3 sunColor, float sunAngle) {
    float day = dayFactor(sunAngle);
    vec3 horizonDay   = vec3(0.75, 0.85, 1.0);
    vec3 zenithDay    = vec3(0.25, 0.45, 0.85);
    vec3 horizonNight = vec3(0.05, 0.07, 0.12);
    vec3 zenithNight  = vec3(0.01, 0.01, 0.03);

    float up = clamp(viewDir.y * 0.5 + 0.5, 0.0, 1.0);
    vec3 horizon = mix(horizonNight, horizonDay, day);
    vec3 zenith  = mix(zenithNight, zenithDay, day);
    vec3 sky = mix(horizon, zenith, pow(up, 0.45));

    // dezenter Sonnenglanz im Himmel
    return sky + sunColor * 0.05 * day;
}

// ---- 4x4 PCF Soft-Shadow-Sampling ----
float sampleShadowPCF(sampler2DShadow shadowMap, vec3 shadowCoord, float texelSize) {
    float result = 0.0;
    const int r = 1;
    float samples = 0.0;
    for (int x = -r; x <= r; x++) {
        for (int y = -r; y <= r; y++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            result += shadow2D(shadowMap, vec3(shadowCoord.xy + offset, shadowCoord.z)).r;
            samples += 1.0;
        }
    }
    return result / samples;
}

// ---- ACES-nahes Filmic Tonemapping ----
vec3 tonemapACES(vec3 color) {
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0.0, 1.0);
}

#endif
