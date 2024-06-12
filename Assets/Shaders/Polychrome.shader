Shader "Custom/Polychrome"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _HueOffset ("Hue Offset", Range(0, 1)) = 0.0
        _SpiralSpeed ("Spiral Speed", Float) = 1.0
        _SpiralDensity ("Spiral Density", Float) = 10.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
            float _HueOffset;
            float _SpiralSpeed;
            float _SpiralDensity;
            float2 _Rotation;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float3 RGBToHSV(float3 rgb)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = lerp(float4(rgb.bg, K.wz), float4(rgb.gb, K.xy), step(rgb.b, rgb.g));
                float4 q = lerp(float4(p.xyw, rgb.r), float4(rgb.r, p.yzx), step(p.x, rgb.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 HSVToRGB(float3 hsv)
            {
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);
                return hsv.z * lerp(K.xxx, saturate(p - K.xxx), hsv.y);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.texcoord;
				_Rotation *= 2.0;
                float2 center = float2(0.5 - _Rotation.x, 0.5 - _Rotation.y);

                float2 toCenter = uv - center;
                float distance = length(toCenter);
                float angle = atan2(toCenter.y, toCenter.x);

                float time = _Time.y * _SpiralSpeed;
                angle += distance * _SpiralDensity + time;

                float hue = frac(angle / (2.0 * UNITY_PI) + _HueOffset);
                float3 hsv = float3(hue, 1.0, 1.0);
                float3 rgb = HSVToRGB(hsv);
                fixed4 col = tex2D(_MainTex, uv);
                col = lerp(col, fixed4(rgb, col.a), 0.5);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

