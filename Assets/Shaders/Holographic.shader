Shader "Custom/Holographic"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {} // A textura principal aplicada � superf�cie.
        _AlphaTexture("Alpha Mask (R)", 2D) = "white" {} // A textura de m�scara alpha que controla a transpar�ncia.
        // Propriedades da m�scara alpha
        _ScrollSpeedV("Alpha scroll Speed", Range(0, 5.0)) = 2.0 // Velocidade de rolagem vertical da m�scara alpha.
        // Brilho
        _GlowIntensity("Glow Intensity", Range(0.01, 1.0)) = 0.5 // Intensidade do efeito de brilho.

        _GlitchSpeed("Glitch Speed", Range(0, 50)) = 50.0
        _GlitchIntensity("Glitch Intensity", Range(0.0, 0.1)) = 0
    }

    SubShader
    {
        Tags { "Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "Transparent" } // Configura��es de renderiza��o para o shader.

        Pass
        {
            Lighting Off // Desativa c�lculos de ilumina��o.
            ZWrite On // Ativa escrita de profundidade.
            Blend SrcAlpha One // Define o modo de mistura para aditivo.
            Cull Off // Desativa o culling.

            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION; // Posi��o do v�rtice.
                float2 uv : TEXCOORD0; // Coordenadas de textura.
            };

            struct v2f {
                float4 position : SV_POSITION; // Posi��o do v�rtice transformada.
                float2 uv : TEXCOORD0; // Coordenadas de textura transformadas.
                float2 grabUV : TEXCOORD1; // Coordenadas UV ajustadas para o espa�o de visualiza��o.
            };

            sampler2D _MainTex, _AlphaTexture;
            half _ScrollSpeedV, _GlowIntensity, _GlitchSpeed, _GlitchIntensity;

            v2f vertexFunc(appdata IN) {
                v2f OUT;

                IN.vertex.y += sin(_Time.y * _GlitchSpeed * 5 * IN.vertex.y) * _GlitchIntensity;

                OUT.position = UnityObjectToClipPos(IN.vertex); // Transforma a posi��o do v�rtice para o espa�o de recorte.
                OUT.uv = IN.uv; // Transforma as coordenadas UV para a textura principal.

                OUT.grabUV = IN.uv;
                OUT.grabUV.y += _Time * _ScrollSpeedV; // Rola a coordenada y com base no tempo e na velocidade de rolagem.

                return OUT;
            }

            fixed4 fragmentFunc(v2f IN) : SV_Target {

                fixed4 alphaColor = tex2D(_AlphaTexture, IN.grabUV); // Amostra a textura da m�scara alpha.
                fixed4 pixelColor = tex2D(_MainTex, IN.uv); // Amostra a textura principal.
                pixelColor.w = alphaColor.w; // Define o valor alpha da textura principal para o valor alpha da m�scara alpha.

                // Luz de contorno (rim light)
                half rim = 1.0 - saturate(dot(float3(0, 0, -1), float3(0, 0, 1))); // Ajuste para 2D

                return pixelColor * (rim + _GlowIntensity); // Modula a cor final com a luz de contorno e a intensidade do brilho.
            }
            ENDCG
        }
    }
}
