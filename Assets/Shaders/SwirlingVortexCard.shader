Shader "Unlit/SwirlingVortexCard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}  // Textura principal
        _SwirlSize ("Swirl Size", Range(1, 20)) = 10.0  // Tamanho do redemoinho
        _SwirlGap ("Swirl Gap", Range(0, 1)) = 0.1  // Espaçamento do redemoinho
        _LineWidth ("Line Width", Range(0.1, 1.0)) = 0.1  // Largura da linha
        _TimeFactor ("Time Factor", Range(0.1, 10.0)) = 1.0  // Fator de tempo para animar o redemoinho
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
                float4 vertex : POSITION;  // Posição do vértice
                float2 uv : TEXCOORD0;  // Coordenada UV
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;  // Coordenada UV
                float4 vertex : SV_POSITION;  // Posição do vértice na tela
                float2 centeredUV : TEXCOORD1;  // Coordenada UV centrada
            };

            sampler2D _MainTex;  // Amostrador para a textura principal
            float4 _MainTex_ST;  // Transformações da textura principal
            float _SwirlSize;  // Tamanho do redemoinho
            float _SwirlGap;  // Espaçamento do redemoinho
            float _LineWidth;  // Largura da linha
            float _TimeFactor;  // Fator de tempo para animar o redemoinho
            bool _CardSelected;  // Indica se o cartão está selecionado

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Converte a posição do objeto para posição de clip
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);  // Transforma a coordenada de textura
                
                // Centraliza as coordenadas UV
                o.centeredUV = o.uv - 0.5;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 p = i.centeredUV;

                // Calcula o ângulo com base nas coordenadas UV centradas
                float angle = atan2(p.y, p.x) + length(p) * _SwirlSize + _Time.y * _TimeFactor;

                // Roda as coordenadas para criar o efeito de redemoinho
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                float2 rotatedUV = float2(cosAngle * p.x - sinAngle * p.y, sinAngle * p.x + cosAngle * p.y);

                // Ajusta as coordenadas UV de volta para o intervalo [0, 1]
                rotatedUV += 0.5;

                // Amostra a textura principal com as coordenadas UV originais
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                // Calcula as linhas do redemoinho com base nas coordenadas rodadas
                float pattern = frac(rotatedUV.x * 10.0 / (1.0 + _SwirlGap));
                _LineWidth *= abs(sin(_Time.y * _TimeFactor));  // Ajusta a largura da linha com base no tempo
                float linePattern = step(pattern, _LineWidth);

                // Inverte o redemoinho se o cartão estiver selecionado
                if (_CardSelected)
                    linePattern = 1.0 - linePattern;

                // Cria as linhas do redemoinho com a cor e alfa especificados
                fixed4 lineColor = fixed4(0.0, 0.0, 0.0, linePattern);
                
                // Descarta o fragmento se a linha não for transparente
                if (lineColor.a != 0.0)
                    discard;

                // Retorna a cor da textura ou a cor da linha
                return lineColor.a > 0.0 ? lineColor : texColor;
            }
            ENDCG
        }
    }
}

