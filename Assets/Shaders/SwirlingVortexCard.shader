Shader "Unlit/SwirlingVortexCard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            #define STEPS 128 
            #define STEP_SIZE 0.02

            float SphereDistance(float3 p, float3 center, float radius)
            {
                return length(p - center) - radius;
            }

            float3 RotateY(float3 p, float angle)
            {
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                return float3(cosAngle * p.x + sinAngle * p.z, p.y, -sinAngle * p.x + cosAngle * p.z);
            }

            float3 RotateX(float3 p, float angle)
            {
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);
                return float3(p.x, cosAngle * p.y - sinAngle * p.z, sinAngle * p.y + cosAngle * p.z);
            }

            float RayMarchDistance(float3 p)
            {
                float3 swirlCenterY = RotateY(p, length(p.xy) * 10.0);
                float3 swirlCenter = RotateX(swirlCenterY, length(swirlCenterY.yz) * 10.0);
				swirlCenter.z -= 1.0;
                return SphereDistance(swirlCenter, float3(0, 0, 0), 0.5);
            }

            float RayMarch(float3 origin, float3 direction)
            {
                float totalDistance = 0.0;
                for (int i = 0; i < STEPS; i++)
                {
                    float3 p = origin + totalDistance * direction;
                    float d = RayMarchDistance(p);
                    if (d < STEP_SIZE)
                        return totalDistance;
                    totalDistance += d * 0.5;
                }
                return 0.0;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
                float depth = RayMarch(i.wPos, viewDir);

                if (depth > 0.0)
                {
                    return fixed4(1.0 - depth, depth * 0.5, depth, 1.0);
                }
                else
                {
                    // Debugging color for no intersection
                    return tex2D(_MainTex, i.uv);
                }
            }
            ENDCG
        }
    }
}

