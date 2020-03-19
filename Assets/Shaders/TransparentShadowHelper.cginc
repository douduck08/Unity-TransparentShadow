#ifndef TRANSPARENT_SHADOW_HELPER_INCLUDE
#define TRANSPARENT_SHADOW_HELPER_INCLUDE

// sampler2D _CascadeShadowMapTexture;
UNITY_DECLARE_SHADOWMAP(_CascadeShadowMapTexture);

float4x4 transparentShadow_VP;
sampler2D transparentShadow_map;
sampler2D transparentShadow_depth;

inline fixed4 getCascadeWeights_splitSpheres(float3 wpos) {
    float3 fromCenter0 = wpos.xyz - unity_ShadowSplitSpheres[0].xyz;
    float3 fromCenter1 = wpos.xyz - unity_ShadowSplitSpheres[1].xyz;
    float3 fromCenter2 = wpos.xyz - unity_ShadowSplitSpheres[2].xyz;
    float3 fromCenter3 = wpos.xyz - unity_ShadowSplitSpheres[3].xyz;
    float4 distances2 = float4(dot(fromCenter0, fromCenter0), dot(fromCenter1, fromCenter1), dot(fromCenter2, fromCenter2), dot(fromCenter3, fromCenter3));
    fixed4 weights = float4(distances2 < unity_ShadowSplitSqRadii);
    weights.yzw = saturate(weights.yzw - weights.xyz);
    return weights;
}

inline float4 getCascadeShadowCoord(float4 wpos, fixed4 cascadeWeights) {
    float3 sc0 = mul(unity_WorldToShadow[0], wpos).xyz;
    float3 sc1 = mul(unity_WorldToShadow[1], wpos).xyz;
    float3 sc2 = mul(unity_WorldToShadow[2], wpos).xyz;
    float3 sc3 = mul(unity_WorldToShadow[3], wpos).xyz;
    float4 shadowMapCoordinate = float4(sc0 * cascadeWeights[0] + sc1 * cascadeWeights[1] + sc2 * cascadeWeights[2] + sc3 * cascadeWeights[3], 1);
    #if defined(UNITY_REVERSED_Z)
    float noCascadeWeights = 1 - dot(cascadeWeights, float4(1, 1, 1, 1));
    shadowMapCoordinate.z += noCascadeWeights;
    #endif
    return shadowMapCoordinate;
}

inline half3 getTransShadowColor(float3 worldPos) {
    float4 lightSpacePos = mul(transparentShadow_VP, float4(worldPos, 1));
    float2 shadow_uv = (lightSpacePos.xy / lightSpacePos.w) / 2.0f + 0.5f;
    half3 transShadow = tex2D(transparentShadow_map, shadow_uv).rgb;
    // half transShadowDepth = tex2D(transparentShadow_depth, shadow_uv).r;
    // half shadow = transShadowDepth > (lightSpacePos.z / lightSpacePos.w) ? 1.0 : 0.0;
    return transShadow;
}

#endif // TRANSPARENT_SHADOW_HELPER_INCLUDE