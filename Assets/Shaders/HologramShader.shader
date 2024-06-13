Shader "Custom/HologramShader"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _HoloTex("Hologram Texture", 2D) = "white" {}
        _HoloColor("Hologram Color", Color) = (0,1,1,1)
        _HoverTex("Hover Texture", 2D) = "white" {}
        _CardRotation("Card Rotation", Vector) = (0,0,0,0)
        _MouseHovering("Mouse Hovering", Float) = 0
        _CardSelected("Card Selected", Float) = 0
        _CardDragging("Card Dragging", Float) = 0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows

            sampler2D _MainTex;
            sampler2D _HoloTex;
            sampler2D _HoverTex;
            fixed4 _HoloColor;
            float4 _CardRotation;
            float _MouseHovering;
            float _CardSelected;
            float _CardDragging;

            struct Input
            {
                float2 uv_MainTex;
            };

            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

                if (_CardDragging > 0)
                {
                    c.rgb = lerp(c.rgb, _HoloColor.rgb, 0.5);
                    c.a = 1;
                }

                if (_MouseHovering > 0)
                {
                    c.rgb = tex2D(_HoverTex, IN.uv_MainTex).rgb;
                }

                if (_CardSelected > 0)
                {
                    c.rgb = tex2D(_HoloTex, IN.uv_MainTex).rgb;
                }

                o.Albedo = c.rgb;
                o.Alpha = c.a;
            }
            ENDCG
        }
            FallBack "Diffuse"
}
