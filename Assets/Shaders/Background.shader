Shader "Custom/Background"
{
    Properties
    {
        _Color("Color", Color) = (1, 0.92, 0.6, 1)
        _MainTex("Texture", 2D) = "white" {}
        _HighlightColor("Highlight Color", Color) = (1, 1, 1, 1)
        _BorderColor("Border Color", Color) = (0.9, 0.7, 0.3, 1)
        _BorderWidth("Border Width", Range(0.01, 0.1)) = 0.05
        _MousePosition("Mouse Position", Vector) = (0, 0, 0, 0)
        _Glossiness("Glossiness", Range(0,1)) = 0.5
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
                float4 _Color;
                float4 _HighlightColor;
                float4 _BorderColor;
                float _BorderWidth;
                float2 _MousePosition;
                float _Glossiness;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                // Add border
                float2 borderDist = abs(i.uv - 0.5);
                if (max(borderDist.x, borderDist.y) > (0.5 - _BorderWidth))
                {
                    col = _BorderColor;
                }

                // Add highlights
                float2 highlightPos1 = _MousePosition * -8;
                float2 highlightPos2 = _MousePosition * -12;
                float highlightSize = _Glossiness;
                float highlight1 = smoothstep(highlightSize, highlightSize - 0.01, length(i.uv - highlightPos1));
                float highlight2 = smoothstep(highlightSize, highlightSize - 0.01, length(i.uv - highlightPos2));
                col.rgb += _HighlightColor.rgb * (highlight1 + highlight2);

                return col;
            }
            ENDCG
        }
        }
            FallBack "Diffuse"
}
