Shader "Custom/Stencil"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        [IntRange] _StencilRef ("Stencil Ref", Range(0, 255)) = 1
        _CircleCenter ("Circle Center", Vector) = (0.5, 0.5, 0, 0)
        _CircleRadius ("Circle Radius", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
		ZWrite Off

		// Stencil rendering inside the circle
        Pass
        {
            Stencil
            {
                Ref [_StencilRef]
                Comp Always
                Pass Replace
                Fail Keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragStencil
            #include "UnityCG.cginc"
            
            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 texcoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _CircleCenter;
            float _CircleRadius;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            fixed4 fragStencil(v2f i) : SV_Target
            {
                float2 circleCenter = _CircleCenter;
                float radius = _CircleRadius;
                
                float2 uv = i.texcoord;
                float dis = distance(uv, circleCenter);
                
                if (dis <= radius)
                {
					float4 color = tex2D(_MainTex, i.texcoord);
					color.a = 0;
					return color;
                }
                else
                {
					discard;
					return fixed4(1, 1, 1, 1);
                }
            }
            ENDCG
        }

		// Normal rendering outside the circle
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragTexture
            #include "UnityCG.cginc"
            
            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 texcoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _CircleCenter;
            float _CircleRadius;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            fixed4 fragTexture(v2f i) : SV_Target
            {
                float2 circleCenter = _CircleCenter;
                float radius = _CircleRadius;
                
                float2 uv = i.texcoord;
                float dis = distance(uv, circleCenter);
                
                if (dis <= radius)
                {
                    discard;
                }
				return tex2D(_MainTex, i.texcoord);
            }
            ENDCG
        }
    }
}

