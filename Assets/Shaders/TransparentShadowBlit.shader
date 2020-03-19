Shader "Hidden/TransparentShadowBlend" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"
        // #include "TransparentShadowHelper.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float3 worldPos : TEXCOORD0;
        };

        // sampler2D _CascadeShadowMapTexture;
        // UNITY_DECLARE_SHADOWMAP(_CascadeShadowMapTexture);
        UNITY_DECLARE_TEX2D(_CascadeShadowMapTexture);
        UNITY_DECLARE_TEX2D(_CameraDepthTexture);

        float4x4 transparentShadow_inverseVP;

        v2f vert(appdata v) {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.worldPos = mul(transparentShadow_inverseVP, float4(v.uv * 2.0 - 1.0, 1, 1)).xyz;
            return o;
        }

        float frag(v2f i) : SV_Target {
            float3 sc0 = mul(unity_WorldToShadow[0], float4(i.worldPos, 1)).xyz;
            // float4 depth = tex2D(_CascadeShadowMapTexture, sc0.xy);
            // float4 depth = UNITY_SAMPLE_TEX2D(_CascadeShadowMapTexture, sc0.xy);
            // float4 depth = UNITY_SAMPLE_TEX2D(_CameraDepthTexture, sc0.xy);
            float4 depth = _CascadeShadowMapTexture.Load(float3(sc0.xy,0));
            return depth.r;
        }

        ENDCG

        // Pass 0: copy shadow map
        Pass {
            Blend One Zero
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }
}
