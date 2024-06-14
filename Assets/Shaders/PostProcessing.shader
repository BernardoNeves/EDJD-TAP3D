Shader "Custom/PostProcessing"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _BorderColor("Border Color", Color) = (1,1,1,1)
        _BorderThickness("Border Thickness", Float) = 0.05
        _ApplyGrayscale("Apply Grayscale", Float) = 0.0
        _CenterTex("Center Texture", 2D) = "white" {} // New property
        _HaveText("Have Text", Float) = 0.0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                Stencil {
                    Ref 1
                    Comp NotEqual
                    Pass Keep
                }

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
                sampler2D _CenterTex;
                float4 _BorderColor;
                float _BorderThickness;
                float _ApplyGrayscale;
                float _HaveText;

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

                    if (i.uv.x < _BorderThickness || i.uv.x > 1.0 - _BorderThickness ||
                        i.uv.y < _BorderThickness || i.uv.y > 1.0 - _BorderThickness)
                    {
                        col = _BorderColor;
                    }
                    else if (_ApplyGrayscale > 0.0)
                    {
                        // Apply grayscale effect
                        float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));
                        col.rgb = float3(gray, gray, gray);
                    }

                    if (_HaveText > 0.0) // Corrected condition
                    {
                        // Center UV coordinates
                        float2 centerUV = (i.uv - 0.5) * 2.0; // Center the UV coordinates around (0,0)

                        // Adjust the size of the center texture
                        float scale = 0.5; // Adjust this value to scale the center texture
                        centerUV /= scale;

                        if (abs(centerUV.x) < 1.0 && abs(centerUV.y) < 1.0)
                        {
                            half4 centerTexCol = tex2D(_CenterTex, centerUV * 0.5 + 0.5);
                            col = lerp(col, centerTexCol, centerTexCol.a); // Blend based on alpha
                        }
                    }

                    return col;
                }
                ENDCG
            }
        }
}
