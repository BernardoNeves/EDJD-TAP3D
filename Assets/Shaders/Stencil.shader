Shader "Custom/Stencil"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
		_BackTex ("Background Texture", 2D) = "white" {}
        [IntRange] _StencilRef ("Stencil Ref", Range(0, 255)) = 1
        _EdgeThreshold ("Edge Threshold", Float) = 0.05
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        // Stencil rendering inside the rectangle edge
        Pass
        {
            ZWrite Off
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
            float _EdgeThreshold;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            fixed4 fragStencil(v2f i) : SV_Target
            {
                float edgeThreshold = _EdgeThreshold;
                
                float2 uv = i.texcoord;
                float left = edgeThreshold;
                float right = 1.0 - edgeThreshold;
                float bottom = edgeThreshold;
                float top = 1.0 - edgeThreshold;
                
                if (uv.x < left || uv.x > right || uv.y < bottom || uv.y > top)
                {
                    discard;
                }

                return float4(0.5, 0.5, 0.5, 1);
            }
            ENDCG
        }

        // Normal rendering outside the rectangle edge
        Pass
        {
            ZWrite On
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
			sampler2D _BackTex;
            float4 _MainTex_ST;
            float _EdgeThreshold;
			bool _MouseHovering;
			bool _CardDragging;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.vertex.z += 0.001;
                return o;
            }
            
            fixed4 fragTexture(v2f i) : SV_Target
            {
                float edgeThreshold = _EdgeThreshold;
                float2 uv = i.texcoord;
                float left = edgeThreshold;
                float right = 1.0 - edgeThreshold;
                float bottom = edgeThreshold;
                float top = 1.0 - edgeThreshold;
                float4 col = tex2D(_MainTex, i.texcoord);
                
                float lineThickness = 0.02;
                float time = _Time.y * 2.0;
                float2 center = float2(0.5, 0.5);

                // Spinning edge effect
                float2 direction = normalize(uv - center);
                float angle = atan2(direction.y, direction.x)*3 + time;
				if(_CardDragging)
					angle *= 1.5;
                float edgeValue = (sin(angle * 10.0) * 0.5 + 0.5);

                if (uv.x > left && uv.x < right && uv.y > bottom && uv.y < top)
                {
					if (!_MouseHovering && !_CardDragging)
						return tex2D(_BackTex, i.texcoord);
					discard;
                }
                else if (
                    abs(uv.x - left) <= lineThickness && uv.y >= bottom && uv.y <= top ||
                    abs(uv.x - right) <= lineThickness && uv.y >= bottom && uv.y <= top ||
                    abs(uv.y - bottom) <= lineThickness && uv.x >= left && uv.x <= right ||
                    abs(uv.y - top) <= lineThickness && uv.x >= left && uv.x <= right)
                {
					col = float4(0.5, 0.5, 0.5, 1);
					col = float4(0, 0, 0, 1);
					col = lerp(col, float4(1, 1, 1, 1), edgeValue);
                }
                return col;
            }
            ENDCG
        }
    }
}

