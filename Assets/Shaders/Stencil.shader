Shader "Custom/Stencil"
{
	Properties
	{
		_GlassTex ("Glass (RGB)", 2D) = "white"{}
		_GlassColor ("Glass Color", Color) = (1,1,1,1)
		_GlassAlpha ("Glass Alpha", Range(0,1)) = 0.75
		_GlassEdge ("Glass Edge", Range(0,1)) = 0.5
		_LiquidColor ("Liquid Color", Color) = (0,0,1,1)
		_LavaColor ("Lava Color", Color) = (1,0,0,1)
		_LavaScale ("Lava Scale", Range(1, 100)) = 1
		_LavaSpeed ("Lava Speed", Range(0, 10)) = 1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 200
		CGPROGRAM
		#pragma surface surf BlinnPhong alpha

		sampler2D _GlassTex;

		struct Input
		{
			float2 uv_GlassTex;
			float2 uv_BaseTex;
			float3 worldPos;
			float3 viewDir;
		};

		fixed4 _GlassColor;
		float _GlassAlpha;
		float _GlassEdge;
		fixed4 _LiquidColor;
		fixed4 _LavaColor;
		float _LavaScale;
		float _LavaSpeed;

		float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
		float2 mod289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

		float3 permute(float3 x) { return mod289(((x * 34.0) + 1.0) * x); }

		float snoise(float2 v)
		{
			const float4 C = float4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
			float2 i = floor(v + dot(v, C.yy));
			float2 x0 = v - i + dot(i, C.xx);
			float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod289(i); 
			float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
			float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac(p * C.www) - 1.0;
			float3 h = abs(x) - 0.5;
			float3 ox = floor(x + 0.5);
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot(m, g);
		}

		float3 LavaEffect(float2 uv, float time, float speed, float scale)
		{
			uv.x *= _ScreenParams.y / _ScreenParams.x;
			float2 pos = uv * 2 / (scale*0.1);


			float2 vel = float2(time * 0.1 * speed, time * 0.1 * speed);
			float DF = snoise(pos + vel) * 0.25 + 0.25;

			float a = snoise(pos * float2(cos(time * 0.15*speed), sin(time * 0.1*speed)) * 0.1) * 3.1415;
			vel = float2(cos(a), sin(a));
			DF += snoise(pos + vel) * 0.25 + 0.25;

			return smoothstep(0.7, 0.75, frac(DF));
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			float objectHeight = unity_ObjectToWorld[1][1] * 2;
			float localY = IN.worldPos.z - mul(unity_ObjectToWorld, float4(0,0,0,1)).z;

			fixed4 glass = tex2D(_GlassTex, IN.uv_GlassTex);


			o.Alpha = glass.a * _GlassAlpha;


			float3 lavaColor = LavaEffect(IN.uv_GlassTex, _Time.y, _LavaSpeed, _LavaScale) * _LavaColor.rgb;
			bool isLavaVisible = any(lavaColor > 0);
			lavaColor.rgb *= 0.5;
			_LiquidColor.rgb *= 0.5;

			o.Albedo = isLavaVisible ? (glass.rgb * lavaColor) : (glass.rgb * _LiquidColor.rgb);
			o.Alpha = isLavaVisible ? _LavaColor.a : _LiquidColor.a;
			o.Emission = isLavaVisible ? lavaColor : 0;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

