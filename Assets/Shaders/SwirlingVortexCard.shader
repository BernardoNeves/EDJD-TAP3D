Shader "Unlit/SwirlingVortexCard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SwirlSize ("Swirl Size", Range(1, 20)) = 10.0
        _SwirlGap ("Swirl Gap", Range(0, 1)) = 0.1
        _LineWidth ("Line Width", Range(0.1, 1.0)) = 0.1
		_TimeFactor ("Time Factor", Range(0.1, 10.0)) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

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
                float2 centeredUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _SwirlSize;
            float _SwirlGap;
            float _LineWidth;
			float _TimeFactor;
			bool _CardSelected;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // Center the UV coordinates
                o.centeredUV = o.uv - 0.5;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = i.centeredUV;

                // Calculate the angle based on centered UV coordinates
                float angle = atan2(p.y, p.x) + length(p) * _SwirlSize + _Time.y * _TimeFactor;

                // Rotate the coordinates to create the swirl effect
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                float2 rotatedUV = float2(cosAngle * p.x - sinAngle * p.y, sinAngle * p.x + cosAngle * p.y);
					

                // Adjust the UV back to [0, 1] range
                rotatedUV += 0.5;

                // Sample the main texture with the original UV coordinates
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                // Calculate the swirl lines based on the rotated coordinates
                float pattern = frac(rotatedUV.x * 10.0 / (1.0 + _SwirlGap));
				_LineWidth *= abs(sin(_Time.y * _TimeFactor));
                float linePattern = step(pattern, _LineWidth);
				//invert the swirl
				if (_CardSelected)
					linePattern = 1.0 - linePattern;

                // Create the swirl lines with the specified color and alpha
                fixed4 lineColor = fixed4(0.0, 0.0, 0.0, linePattern);
				if (lineColor.a != 0.0)
					discard;

                // Return the texture color or the line color
                return lineColor.a > 0.0 ? lineColor : texColor;
            }
            ENDCG
        }
    }
}

