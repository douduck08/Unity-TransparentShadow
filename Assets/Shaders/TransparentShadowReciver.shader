Shader "Custom/TransparentShadowReciver" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf StandardWithShadow fullforwardshadows
        #pragma target 3.0

        #include "UnityPBSLighting.cginc"
        #include "TransparentShadowHelper.cginc"

        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
        };

        struct SurfaceOutputStandardWithShadow {
            half3 Albedo;      // base (diffuse or specular) color
            float3 Normal;      // tangent space normal, if written
            half3 Emission;
            half Metallic;      // 0=non-metal, 1=metal
            half Smoothness;    // 0=rough, 1=smooth
            half Occlusion;     // occlusion (default 1)
            half Alpha;        // alpha for transparencies
            half3 TransShadow;
        };

        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;
        half4 _Color;

        void surf (Input IN, inout SurfaceOutputStandardWithShadow o) {
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.TransShadow = getTransShadowColor(IN.worldPos);
        }

        inline half4 LightingStandardWithShadow (SurfaceOutputStandardWithShadow s, float3 viewDir, UnityGI gi) {
            s.Normal = normalize(s.Normal);

            half oneMinusReflectivity;
            half3 specColor;
            s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

            half outputAlpha;
            s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

            gi.light.color.rgb *= s.TransShadow;

            half4 c = UNITY_BRDF_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
            c.a = outputAlpha;
            return c;
        }

        inline void LightingStandardWithShadow_GI (SurfaceOutputStandardWithShadow s, UnityGIInput data, inout UnityGI gi) {
            #if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
            gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
            #else
            Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
            gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
            #endif
        }
        ENDCG
    }
    FallBack "Diffuse"
}
