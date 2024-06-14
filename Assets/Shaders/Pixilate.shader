Shader "Custom/Pixelate"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Pixelization ("_Pixelization Amount", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
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
            float _Pixelization;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
				if (_Pixelization == 0)
					return tex2D(_MainTex, i.uv);
                float pixelationAmount = lerp(100.0, 1.0, _Pixelization);
                float2 pixelSize = float2(1.0 / pixelationAmount, 1.0 / pixelationAmount);
                float2 uv = floor(i.uv / pixelSize) * pixelSize;

                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

