Shader "Custom/StencilObject"
{
    Properties
    {
        _InsideTex ("Inside Texture", 2D) = "white" {}
        [IntRange] _StencilRef ("Stencil Ref", Range(0, 255)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        LOD 100

        Stencil
        {
            Ref [_StencilRef]
            Comp Equal
            Pass Keep
            Fail Keep
        }

        Pass
        {
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
            
            sampler2D _InsideTex;
            float4 _InsideTex_ST;
            
            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _InsideTex);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                return tex2D(_InsideTex, i.texcoord);
            }
            ENDCG
        }
    }
}

