Shader "Custom/Background"
{
    Properties
    {
        _Color("Color", Color) = (1, 0.92, 0.6, 1) // Cor base do fundo
        _MainTex("Texture", 2D) = "white" {} // Textura principal aplicada ao fundo
        _HighlightColor("Highlight Color", Color) = (1, 1, 1, 1) // Cor usada para os destaques
        _BorderColor("Border Color", Color) = (0.9, 0.7, 0.3, 1) // Cor da borda ao redor do fundo
        _BorderWidth("Border Width", Range(0.01, 0.1)) = 0.05 // Largura da borda, variando de 0.01 a 0.1
        _MousePosition("Mouse Position", Vector) = (0, 0, 0, 0) // Posi��o do mouse usada para calcular os destaques
        _Glossiness("Glossiness", Range(0,1)) = 0.5 // Define o tamanho do destaque
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" } // Define que o shader � opaco
            LOD 100 // Define o n�vel de detalhe para o shader

            Pass
            {
                CGPROGRAM
                #pragma vertex vert // Especifica a fun��o de v�rtice
                #pragma fragment frag // Especifica a fun��o de fragmento
                #include "UnityCG.cginc" // Inclui fun��es e vari�veis comuns do Unity

                struct appdata
                {
                    float4 vertex : POSITION; // Posi��o do v�rtice
                    float2 uv : TEXCOORD0; // Coordenadas UV para texturiza��o
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0; // Coordenadas UV interpoladas
                    float4 vertex : SV_POSITION; // Posi��o do v�rtice transformada
                };

                sampler2D _MainTex; // Sampler para a textura principal
                float4 _Color; // Cor base do fundo
                float4 _HighlightColor; // Cor para os destaques
                float4 _BorderColor; // Cor da borda
                float _BorderWidth; // Largura da borda
                float2 _MousePosition; // Posi��o do mouse
                float _Glossiness; // Tamanho do destaque

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex); // Transforma a posi��o do objeto em coordenadas de clip
                    o.uv = v.uv; // Passa as coordenadas UV para o fragmento
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv) * _Color; // Aplica a textura e a cor base

                // Adiciona borda
                float2 borderDist = abs(i.uv - 0.5); // Calcula a dist�ncia at� o centro da textura
                if (max(borderDist.x, borderDist.y) > (0.5 - _BorderWidth))
                {
                    col = _BorderColor; // Se a dist�ncia � maior que o limite, aplica a cor da borda
                }

                // Adiciona destaques
                float2 highlightPos1 = _MousePosition * -8; // Posi��o do primeiro destaque
                float2 highlightPos2 = _MousePosition * -12; // Posi��o do segundo destaque
                float highlightSize = _Glossiness; // Tamanho do destaque
                float highlight1 = smoothstep(highlightSize, highlightSize - 0.01, length(i.uv - highlightPos1)); // Calcula a intensidade do primeiro destaque
                float highlight2 = smoothstep(highlightSize, highlightSize - 0.01, length(i.uv - highlightPos2)); // Calcula a intensidade do segundo destaque
                col.rgb += _HighlightColor.rgb * (highlight1 + highlight2); // Adiciona a cor do destaque � cor final

                return col; // Retorna a cor final
            }
            ENDCG
        }
        }
            FallBack "Diffuse" // Shader de fallback para dispositivos que n�o suportam este shader
}
