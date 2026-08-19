#version 120

#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform float sunAngle;
uniform float rainStrength;
uniform int isEyeInWater;
uniform float far;
uniform float near;

#define FOG_DENSITY 1.0

varying vec2 texCoord;

float linearizeDepth(float d) {
    return (2.0 * near * far) / (far + near - (d * 2.0 - 1.0) * (far - near));
}

void main() {
    vec4 color = texture2D(colortex0, texCoord);
    float depth = texture2D(depthtex0, texCoord).r;

    vec3 sunColor = sunlightColor(sunAngle);
    vec3 fogColorSky = approxSkyColor(vec3(0.0, 0.2, -1.0), sunColor, sunAngle);

    if (isEyeInWater == 1) {
        // ---- Unterwasser-Nebel ----
        float dist = linearizeDepth(depth);
        float fog = 1.0 - exp(-dist * 0.06);
        vec3 waterFogColor = vec3(0.02, 0.09, 0.14) + sunColor * 0.03;
        color.rgb = mix(color.rgb, waterFogColor, clamp(fog, 0.0, 1.0));
    } else if (depth < 1.0) {
        float dist = linearizeDepth(depth);

        // Rekonstruiere View-Space-Position fuer Hoehen-Nebel
        vec4 ndc = vec4(texCoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
        vec4 viewPos = gbufferProjectionInverse * ndc;
        viewPos /= viewPos.w;
        vec3 worldDir = normalize((gbufferModelViewInverse * vec4(viewPos.xyz, 0.0)).xyz);

        float density = (0.0028 + rainStrength * 0.006) * FOG_DENSITY;
        float heightFalloff = clamp(1.0 - worldDir.y * 0.4, 0.3, 1.6);
        float fog = 1.0 - exp(-dist * density * heightFalloff);
        fog = clamp(fog, 0.0, 0.92);

        color.rgb = mix(color.rgb, fogColorSky, fog);
    }

    gl_FragData[0] = color;
}
