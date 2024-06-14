Shader "Custom/PostProcessingWithMouse"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _OverlayTex("Overlay Texture", 2D) = "white" {}
        _MousePos("Mouse Position", Vector) = (0.5, 0.5, 0, 0)
        _OverlayTransparency("Overlay Transparency", Float) = 0.5
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
                sampler2D _OverlayTex;
                float4 _MousePos;
                float _OverlayTransparency;

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

                    // Calculate the overlay UV coordinates
                    float2 overlayUV = (i.uv - _MousePos.xy) / 0.2 + 0.5;

                    // Only blend the overlay texture if within the bounds
                    if (overlayUV.x >= 0.0 && overlayUV.x <= 1.0 && overlayUV.y >= 0.0 && overlayUV.y <= 1.0)
                    {
                        half4 overlayCol = tex2D(_OverlayTex, overlayUV);
                        overlayCol.a *= _OverlayTransparency;
                        col = lerp(col, overlayCol, overlayCol.a);
                    }

                    return col;
                }
                ENDCG
            }
        }
}
