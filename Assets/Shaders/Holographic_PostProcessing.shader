Shader "Hidden/HologramPostProcessing"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _Intensity("Intensity", Range(0, 1)) = 0.5
        _Speed("Speed", Range(0, 5)) = 1.0
        _RippleScale("Ripple Scale", Range(0, 10)) = 1.0
        _NoiseColor("Noise Color", Color) = (1, 1, 1, 1)
    }
        SubShader
        {
            Tags { "RenderType" = "Transparent" "Queue" = "Overlay-1" }
            LOD 100
            ZTest Always

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                sampler2D _NoiseTex;
                float _Intensity;
                float _Speed;
                float _RippleScale;
                float4 _NoiseColor;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float timeOffset = sin(_Time.y * _Speed) * _RippleScale;
                    float2 uvOffset = float2(i.uv.x, i.uv.y + timeOffset);

                    fixed4 col = tex2D(_MainTex, i.uv);
                    fixed4 noise = tex2D(_NoiseTex, uvOffset);

                    // Apply color to the noise texture
                    noise.rgb *= _NoiseColor.rgb;

                    // Blend the original texture with the colored noise texture based on intensity
                    col.rgb = lerp(col.rgb, noise.rgb, _Intensity * noise.r);

                    return col;
                }
                ENDCG
            }
        }
}
