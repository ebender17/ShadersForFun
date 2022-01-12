Shader "Unlit/HealthBar"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct meshdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Health;

            interpolators vert (meshdata v)
            {
                interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (interpolators i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);

                //lerp between red and green with health as t value
                float3 healthbarColor = lerp(float3(1,0,0), float3(0,1,0), _Health);
                float3 bgColor = float3(0, 0, 0);

                //If frag is less than _Health we get true which gives us 1 (or white). 
                //If frag is not less than _Health we get false (0) which gives us black.
                float healthbarMask = _Health > i.uv.x; 

                float3 outColor = lerp(bgColor, healthbarColor, healthbarMask);

                return float4(outColor, 0);
            }
            ENDCG
        }
    }
}
