Shader "Custom/Ripple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}  // Textura principal
        _TimeScale ("Time Scale", Range(0, 10)) = 1.0  // Escala do tempo
        _RippleSpeed ("Ripple Speed", Range(0, 10)) = 1.0  // Velocidade da ondulação
        _RippleFrequency ("Ripple Frequency", Range(0, 10)) = 5.0  // Frequência da ondulação
        _RippleAmplitude ("Ripple Amplitude", Range(0, 1)) = 0.1  // Amplitude da ondulação
        _EdgeThreshold ("Edge Threshold", Range(0, 0.5)) = 0.1  // Limite da borda
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

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
            };

            sampler2D _MainTex;  // Amostrador para a textura principal
            float _TimeScale;  // Escala do tempo
            float _RippleSpeed;  // Velocidade da ondulação
            float _RippleFrequency;  // Frequência da ondulação
            float _RippleAmplitude;  // Amplitude da ondulação
            float _EdgeThreshold;  // Limite da borda
            float2 _MousePosition;  // Posição do rato
            bool _CardSelected;  // Indica se o cartão está selecionado
            bool _CardDragging;  // Indica se o cartão está a ser arrastado

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Converte a posição do objeto para posição de clip
                o.uv = v.uv;  // Mantém a coordenada UV
                return o;
            }

            float ripple(float2 uv, float time)
            {
                float2 center = float2(0.5, 0.5);  // Centro da ondulação
                float dist = distance(uv, center);  // Distância do ponto ao centro
                float ripple = sin(dist * _RippleFrequency - time * _RippleSpeed) * _RippleAmplitude;  // Calcula o efeito de ondulação
                return ripple;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                if(_CardSelected)
                {
                    _RippleSpeed *= 2;  // Aumenta a velocidade da ondulação se o cartão estiver selecionado
                }
                if(_CardDragging)
                {
                    _EdgeThreshold = 0.5;  // Aumenta o limite da borda se o cartão estiver a ser arrastado
                }
                float2 center = float2(0.5, 0.5);  // Centro da ondulação
                center += float2(_MousePosition.x, _MousePosition.y) * 10;  // Ajusta o centro com base na posição do rato
                float time = _Time * _TimeScale;  // Tempo ajustado pela escala do tempo
                float rippleEffect = ripple(i.uv, time);  // Calcula o efeito de ondulação
                float2 displacement = normalize(i.uv - center) * rippleEffect;  // Deslocamento causado pela ondulação

                float dist = distance(i.uv, center);  // Calcula a distância ao centro
                float edgeBlendFactor = 1 - smoothstep(_EdgeThreshold, _EdgeThreshold + 0.1, dist);  // Fator de mistura da borda
                float2 uv = lerp(i.uv, i.uv + displacement, edgeBlendFactor);  // Interpola as coordenadas UV com o deslocamento

                fixed4 col = tex2D(_MainTex, uv);  // Obtém a cor da textura na coordenada UV interpolada
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

