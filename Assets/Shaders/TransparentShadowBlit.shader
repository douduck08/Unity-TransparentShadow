Shader "Hidden/TransparentShadowBlend" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "TransparentShadowHelper.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 ray : TEXCOORD1;
        };

        UNITY_DECLARE_TEX2D(_CameraDepthTexture);
        float4x4 cameraFrustumCorners;
        float4x4 _InverseView;

        float3 GetRayDirection (float2 uv) {
            return cameraFrustumCorners[0].xyz + uv.x * (cameraFrustumCorners[3].xyz - cameraFrustumCorners[0].xyz) + uv.y * (cameraFrustumCorners[1].xyz - cameraFrustumCorners[0].xyz);
        }

        float3 SetupRay(float3 vpos) {
            // Render settings
            float far = _ProjectionParams.z;

            // Perspective: view space vertex position of the far plane
            float3 rayPers = mul(unity_CameraInvProjection, vpos.xyzz * far).xyz;
            return rayPers;
        }

        v2f vert(appdata v) {
            float3 vpos = float3((v.vertex.xy - 0.5) * 2.0, 1);

            v2f o;
            o.vertex = float4(vpos.x, -vpos.y, 1.0, 1.0);
            o.uv = v.uv;
            o.ray = SetupRay(vpos);
            return o;
        }

        float frag(v2f i) : SV_Target {
            // Render settings
            float near = _ProjectionParams.y;
            float far = _ProjectionParams.z;
            
            float depth = UNITY_SAMPLE_TEX2D(_CameraDepthTexture, i.uv.xy);
            float3 vpos = i.ray * Linear01Depth(depth);
            float3 worldPos = mul(_InverseView, float4(vpos, 1)).xyz;

            half3 transShadow = getTransShadowColor(worldPos);
            transShadow = Luminance(transShadow);
            return float4(transShadow, 1);
        }

        ENDCG

        // Pass 0: blend shadow mask
        Pass {
            Blend DstColor Zero
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }
}
