Shader "Custom/StencilObject"
{
    Properties
    {
        _InsideTex ("Inside Texture", 2D) = "white" {}  // Textura interna
        [IntRange] _StencilRef ("Stencil Ref", Range(0, 255)) = 1  // Referência do stencil
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        LOD 100

        // Configuração do stencil
        Stencil
        {
            Ref [_StencilRef]  // Referência do stencil
            Comp Equal  // Comparação: igual
            Pass Keep  // Mantém o valor do stencil se o teste passar
            Fail Keep  // Mantém o valor do stencil se o teste falhar
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct appdata_t
            {
                float4 vertex : POSITION;  // Posição do vértice
                float2 texcoord : TEXCOORD0;  // Coordenada de textura
            };
            
            struct v2f
            {
                float2 texcoord : TEXCOORD0;  // Coordenada de textura
                float4 vertex : SV_POSITION;  // Posição do vértice na tela
            };
            
            sampler2D _InsideTex;  // Amostrador para a textura interna
            float4 _InsideTex_ST;  // Transformações da textura interna
            
            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Converte a posição do objeto para posição de clip
                o.texcoord = TRANSFORM_TEX(v.texcoord, _InsideTex);  // Transforma a coordenada de textura
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_InsideTex, i.texcoord);  // Obtém a cor da textura interna na coordenada UV
                if (col.a <= 0.5f)  // Se a transparência da cor for menor ou igual a 0.5
                {
                    discard;  // Descarte o fragmento
                }
                return col;  // Retorna a cor da textura
            }
            ENDCG
        }
    }
}

