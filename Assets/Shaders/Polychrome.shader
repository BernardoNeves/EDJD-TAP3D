Shader "Custom/Polychrome"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}  // Textura do sprite
        _HueOffset ("Hue Offset", Range(0, 1)) = 0.0  // Deslocamento do matiz
        _SpiralSpeed ("Spiral Speed", Float) = 1.0  // Velocidade da espiral
        _SpiralDensity ("Spiral Density", Float) = 10.0  // Densidade da espiral
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
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
            
            sampler2D _MainTex;  // Amostrador para a textura principal
            float4 _MainTex_ST;  // Transformações da textura principal
            float _HueOffset;  // Deslocamento do matiz
            float _SpiralSpeed;  // Velocidade da espiral
            float _SpiralDensity;  // Densidade da espiral
            float2 _CardRotation;  // Rotação do cartão
            bool _CardSelected;  // Indica se o cartão está selecionado
            bool _CardDragging;  // Indica se o cartão está a ser arrastado

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Converte a posição do objeto para posição de clip
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);  // Transforma a coordenada de textura
                return o;
            }

            // Converte RGB para HSV
            float3 RGBToHSV(float3 rgb)
            {
                float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
                float4 p = lerp(float4(rgb.bg, K.wz), float4(rgb.gb, K.xy), step(rgb.b, rgb.g));
                float4 q = lerp(float4(p.xyw, rgb.r), float4(rgb.r, p.yzx), step(p.x, rgb.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            // Converte HSV para RGB
            float3 HSVToRGB(float3 hsv)
            {
                float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
                float3 p = abs(frac(hsv.xxx + K.xyz) * 6.0 - K.www);
                return hsv.z * lerp(K.xxx, saturate(p - K.xxx), hsv.y);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.texcoord;
                _CardRotation *= 2.0;  // Dobra a rotação do cartão
                float2 center = float2(0.5 - _CardRotation.x, 0.5 - _CardRotation.y);  // Define o centro da espiral

                float2 toCenter = uv - center;  // Vetor do ponto para o centro
                float distance = length(toCenter);  // Distância ao centro
                float angle = atan2(toCenter.y, toCenter.x);  // Ângulo para o centro

                float time = _Time.y * _SpiralSpeed;  // Calcula o tempo multiplicado pela velocidade da espiral
                angle += distance * _SpiralDensity + time;  // Ajusta o ângulo com base na densidade e no tempo

                // Ajusta o ângulo adicionalmente se o cartão estiver selecionado ou arrastado
                if (_CardSelected) {
                    angle += _Time.y * 5.0;
                }
                if (_CardDragging) {
                    angle += _Time.y * 20.0;
                }

                float hue = frac(angle / (2.0 * UNITY_PI) + _HueOffset);  // Calcula o matiz
                float3 hsv = float3(hue, 1.0, 1.0);  // Define o HSV
                float3 rgb = HSVToRGB(hsv);  // Converte para RGB
                fixed4 col = tex2D(_MainTex, uv);  // Obtém a cor da textura na coordenada UV
                col = lerp(col, fixed4(rgb, col.a), 0.5);  // Interpola entre a cor original e a nova cor RGB
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

