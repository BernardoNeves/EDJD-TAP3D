Shader "Custom/Holographic"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {} // A textura principal aplicada à superfície.
        _AlphaTexture("Alpha Mask (R)", 2D) = "white" {} // A textura de máscara alpha que controla a transparência.
        // Propriedades da máscara alpha
        _ScrollSpeedV("Alpha scroll Speed", Range(0, 5.0)) = 2.0 // Velocidade de rolagem vertical da máscara alpha.
        // Brilho
        _GlowIntensity("Glow Intensity", Range(0.01, 1.0)) = 0.5 // Intensidade do efeito de brilho.
    }

        SubShader
        {
            Tags { "Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "Transparent" } // Configurações de renderização para o shader.

            Pass
            {
                Lighting Off // Desativa cálculos de iluminação.
                ZWrite On // Ativa escrita de profundidade.
                Blend SrcAlpha One // Define o modo de mistura para aditivo.
                Cull Back // Ativa o culling de face traseira.

                CGPROGRAM

                #pragma vertex vertexFunc
                #pragma fragment fragmentFunc

                #include "UnityCG.cginc"

                struct appdata {
                    float4 vertex : POSITION; // Posição do vértice.
                    float2 uv : TEXCOORD0; // Coordenadas de textura.
                    float3 normal : NORMAL; // Normal do vértice.
                };

                struct v2f {
                    float4 position : SV_POSITION; // Posição do vértice transformada.
                    float2 uv : TEXCOORD0; // Coordenadas de textura transformadas.
                    float3 grabPos : TEXCOORD1; // Posição no espaço de visualização.
                    float3 viewDir : TEXCOORD2; // Direção de visualização normalizada.
                    float3 worldNormal : NORMAL; // Normal do vértice no espaço mundial.
                };

                fixed4 _MainTex_ST;
                sampler2D _MainTex, _AlphaTexture;
                half _Scale, _ScrollSpeedV, _GlowIntensity;

                v2f vertexFunc(appdata IN) {
                    v2f OUT;

                    OUT.position = UnityObjectToClipPos(IN.vertex); // Transforma a posição do vértice para o espaço de recorte.
                    OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex); // Transforma as coordenadas UV para a textura principal.

                    // Coordenadas da máscara alpha
                    OUT.grabPos = UnityObjectToViewPos(IN.vertex); // Calcula a posição no espaço de visualização.

                    // Rola as coordenadas UV da máscara alpha
                    OUT.grabPos.y += _Time * _ScrollSpeedV; // Rola a coordenada y com base no tempo e na velocidade de rolagem.

                    OUT.worldNormal = UnityObjectToWorldNormal(IN.normal); // Converte a normal do vértice para o espaço mundial.
                    OUT.viewDir = normalize(UnityWorldSpaceViewDir(OUT.grabPos.xyz)); // Calcula a direção de visualização normalizada.

                    return OUT;
                }

                fixed4 fragmentFunc(v2f IN) : SV_Target {

                    fixed4 alphaColor = tex2D(_AlphaTexture, IN.grabPos); // Amostra a textura da máscara alpha.
                    fixed4 pixelColor = tex2D(_MainTex, IN.uv); // Amostra a textura principal.
                    pixelColor.w = alphaColor.w; // Define o valor alpha da textura principal para o valor alpha da máscara alpha.

                    // Luz de contorno (rim light)
                    half rim = 1.0 - saturate(dot(IN.viewDir, IN.worldNormal)); // Calcula o efeito de luz de contorno.

                    return pixelColor * (rim + _GlowIntensity); // Modula a cor final com a luz de contorno e a intensidade do brilho.
                }
            ENDCG
        }
    }
}
