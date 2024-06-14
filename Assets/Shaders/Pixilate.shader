Shader "Custom/Pixelate"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}  // Textura base
        _Pixelization ("_Pixelization Amount", Range(0, 1)) = 1  // Quantidade de pixelização
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always
            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
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
            float _Pixelization;  // Quantidade de pixelização

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Converte a posição do objeto para posição de clip
                o.uv = v.uv;  // Mantém a coordenada UV
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
				if (_Pixelization == 0)
					return tex2D(_MainTex, i.uv);  // Retorna a textura original se a pixelização for zero

                float pixelationAmount = lerp(100.0, 1.0, _Pixelization);  // Calcula a quantidade de pixelização
                float2 pixelSize = float2(1.0 / pixelationAmount, 1.0 / pixelationAmount);  // Tamanho do pixel
                float2 uv = floor(i.uv / pixelSize) * pixelSize;  // Ajusta a coordenada UV para a pixelização

                return tex2D(_MainTex, uv);  // Retorna a cor da textura na coordenada UV pixelizada
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

