Shader "Custom/WaterRippleEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TimeScale ("Time Scale", Range(0, 10)) = 1.0
        _RippleSpeed ("Ripple Speed", Range(0, 10)) = 1.0
        _RippleFrequency ("Ripple Frequency", Range(0, 10)) = 5.0
        _RippleAmplitude ("Ripple Amplitude", Range(0, 1)) = 0.1
        _EdgeThreshold ("Edge Threshold", Range(0, 0.5)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _TimeScale;
            float _RippleSpeed;
            float _RippleFrequency;
            float _RippleAmplitude;
            float _EdgeThreshold;
            float2 _MousePosition;
			bool _CardSelected;
			bool _CardDragging;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float ripple(float2 uv, float time)
            {
                float2 center = float2(0.5, 0.5);
                float dist = distance(uv, center);
                float ripple = sin(dist * _RippleFrequency - time * _RippleSpeed) * _RippleAmplitude;
                return ripple;
            }

            fixed4 frag(v2f i) : SV_Target
            {
				if(_CardSelected)
				{
					_RippleSpeed *= 2;
				}
				if(_CardDragging)
				{
					_EdgeThreshold = 0.5;
				}
				float2 center = float2(0.5, 0.5);
				center += float2(_MousePosition.x, _MousePosition.y) * 10;
                float time = _Time * _TimeScale;
                float rippleEffect = ripple(i.uv, time);
                float2 displacement = normalize(i.uv - center) * rippleEffect;

                float dist = distance(i.uv, center);
                float edgeBlendFactor = 1 - smoothstep(_EdgeThreshold, _EdgeThreshold + 0.1, dist);
                float2 uv = lerp(i.uv, i.uv + displacement, edgeBlendFactor);

                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

