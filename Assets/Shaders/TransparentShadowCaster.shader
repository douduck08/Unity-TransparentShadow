// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "TransparentShadowCaster" {
    Properties {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Cull Off ZWrite On ZTest Always
        Blend DstColor Zero

        // Pass 0: render color buffer
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityDeferredLibrary.cginc"
            #include "TransparentShadowHelper.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;

            // vert shader
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            // frag shader
            half4 frag (v2f i) : SV_Target {
                float3 worldPos = i.worldPos;
                float4 cascadeWeights = getCascadeWeights_splitSpheres(worldPos);
                float4 samplePos = getCascadeShadowCoord(float4(worldPos, 1), cascadeWeights);
                samplePos.z -= 0.003f;
                half shadow = UNITY_SAMPLE_SHADOW(_CascadeShadowMapTexture, samplePos.xyz);
                clip (shadow - 0.5h);
                
                half4 c = tex2D(_MainTex, i.uv) * _Color;
                c.rgb *= c.a;
                c.a = 1;
                return c;
            }
            ENDCG
        }
    }
}
