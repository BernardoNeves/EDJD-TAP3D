Shader "Custom/GrayScale"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ApplyGrayscale("Apply Grayscale", Float) = 0.0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

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
                float _ApplyGrayscale;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                half4 frag(v2f i) : SV_Target
                {
                    half4 col = tex2D(_MainTex, i.uv);

                    if (_ApplyGrayscale > 0.0)
                    {
                        // Apply grayscale effect
                        float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));
                        col.rgb = float3(gray, gray, gray);
                    }

                    return col;
                }
                ENDCG
            }
        }
}
