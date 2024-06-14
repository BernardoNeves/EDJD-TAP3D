Shader "Custom/Stencil"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}  // Textura principal
		_BackTex ("Background Texture", 2D) = "white" {}  // Textura de fundo
        [IntRange] _StencilRef ("Stencil Ref", Range(0, 255)) = 1  // Referência do stencil
        _EdgeThreshold ("Edge Threshold", Float) = 0.05  // Limite de borda
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        // Renderização do stencil dentro do limite do retângulo
        Pass
        {
            ZWrite Off
            Stencil
            {
                Ref [_StencilRef]  // Referência do stencil
                Comp Always  // Comparação sempre
                Pass Replace  // Substitui quando o teste do stencil passar
                Fail Keep  // Mantém o valor do stencil quando o teste falhar
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragStencil
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
            
            sampler2D _MainTex;  // Amostrador para a textura principal
            float4 _MainTex_ST;  // Transformações da textura principal
            float _EdgeThreshold;  // Limite de borda

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Converte a posição do objeto para posição de clip
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);  // Transforma a coordenada de textura
                return o;
            }
            
            fixed4 fragStencil(v2f i) : SV_Target
            {
                float edgeThreshold = _EdgeThreshold;  // Define o limite da borda
                
                float2 uv = i.texcoord;
                float left = edgeThreshold;  // Limite esquerdo
                float right = 1.0 - edgeThreshold;  // Limite direito
                float bottom = edgeThreshold;  // Limite inferior
                float top = 1.0 - edgeThreshold;  // Limite superior
                
                // Descarte os fragmentos fora dos limites definidos
                if (uv.x < left || uv.x > right || uv.y < bottom || uv.y > top)
                {
                    discard;
                }

                return float4(0.5, 0.5, 0.5, 1);  // Cor de retorno
            }
            ENDCG
        }

        // Renderização normal fora do limite do retângulo
        Pass
        {
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragTexture
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
            
            sampler2D _MainTex;  // Amostrador para a textura principal
			sampler2D _BackTex;  // Amostrador para a textura de fundo
            float4 _MainTex_ST;  // Transformações da textura principal
            float _EdgeThreshold;  // Limite de borda
			bool _MouseHovering;  // Indica se o rato está a passar por cima
			bool _CardSelected;  // Indica se o cartão está selecionado
			bool _CardDragging;  // Indica se o cartão está a ser arrastado

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Converte a posição do objeto para posição de clip
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);  // Transforma a coordenada de textura
                o.vertex.z += 0.001;  // Ajusta a profundidade para evitar conflitos de Z
                return o;
            }
            
            fixed4 fragTexture(v2f i) : SV_Target
            {
                float edgeThreshold = _EdgeThreshold;  // Define o limite da borda
                float2 uv = i.texcoord;
                float left = edgeThreshold;  // Limite esquerdo
                float right = 1.0 - edgeThreshold;  // Limite direito
                float bottom = edgeThreshold;  // Limite inferior
                float top = 1.0 - edgeThreshold;  // Limite superior
                float4 col = tex2D(_MainTex, i.texcoord);  // Cor inicial do fragmento
                
                float lineThickness = 0.02;  // Espessura da linha
                float time = _Time.y * 2.0;  // Tempo para animar
                float2 center = float2(0.5, 0.5);  // Centro do retângulo

                // Efeito de borda giratória
                float2 direction = normalize(uv - center);  // Direção do centro para a borda
                float angle = atan2(direction.y, direction.x)*3 + time;  // Ângulo com base na direção e no tempo
				if(_CardDragging)
					angle *= 1.5;  // Aumenta a velocidade do giro quando o cartão está a ser arrastado
                float edgeValue = (sin(angle * 10.0) * 0.5 + 0.5);  // Valor de transição para o efeito de borda

                // Renderiza a textura de fundo se estiver dentro dos limites
                if (uv.x > left && uv.x < right && uv.y > bottom && uv.y < top)
                {
					if (!_CardDragging && !_CardSelected)
						return tex2D(_BackTex, i.texcoord);  // Retorna a textura de fundo
					discard;  // Descarte o fragmento se o cartão estiver selecionado ou arrastado
                }
                // Renderiza a borda com efeito de animação
                else if (
                    abs(uv.x - left) <= lineThickness && uv.y >= bottom && uv.y <= top ||
                    abs(uv.x - right) <= lineThickness && uv.y >= bottom && uv.y <= top ||
                    abs(uv.y - bottom) <= lineThickness && uv.x >= left && uv.x <= right ||
                    abs(uv.y - top) <= lineThickness && uv.x >= left && uv.x <= right)
                {
					col = float4(0.5, 0.5, 0.5, 1);  // Cor de base da borda
					col = float4(0, 0, 0, 1);  // Cor preta
					col = lerp(col, float4(1, 1, 1, 1), edgeValue);  // Interpola entre preto e branco com base no valor da borda
                }
                return col;  // Retorna a cor final do fragmento
            }
            ENDCG
        }
    }
}

