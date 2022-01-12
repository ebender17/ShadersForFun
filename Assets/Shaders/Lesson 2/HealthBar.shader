Shader "Unlit/HealthBar"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}

        Pass
        {
            ZWrite Off //Do not write to depth buffer
            //src * X + dst * Y
            //src - color output of this shader
            //dst - existing color in the frame buffer, existing color of all the things we are rendering to (background)
            //Alpha blending - src * srcAlpha + dst * (1 - srcAlpha) => lerp between src and dst with srcAlpha as t value
            Blend SrcAlpha OneMinusSrcAlpha //Alpha Blending

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

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }


            fixed4 frag (interpolators i) : SV_Target
            {
                float healthbarMask = _Health > i.uv.x; 
                float tHealthColor = saturate(InverseLerp(0.2, 0.8, _Health));
                float3 healthbarColor = lerp(float3(1,0,0), float3(0,1,0), tHealthColor);
                
                return float4(healthbarColor, healthbarMask);
            }

            /*fixed4 frag (interpolators i) : SV_Target
            {
                //If frag is less than _Health we get true which gives us 1 (or white). 
                //If frag is not less than _Health we get false (0) which gives us black.
                float healthbarMask = _Health > i.uv.x; 

                //We have a range of 0 to 1. But now we want at a certain number we want it to be 0 and at another number we want it to be 1.
                //Perfect use case for inverse lerp.
                //Wherever health value is 0.2 we want 0
                //Wherever health value is 0.8 we want 1
                //use saturate to clamp, saturate = clamp
                //Inservse Lerp is not clamped by default so will go into negeative numbers if goes below 0.2
                float tHealthColor = saturate(InverseLerp(0.2, 0.8, _Health));

                //lerp between red and green with health as t value
                float3 healthbarColor = lerp(float3(1,0,0), float3(0,1,0), tHealthColor);
                
                //float3 bgColor = float3(0, 0, 0);

                //Discards fragments less than 0
                //So subtract small number so fragments == 0 will be < 0 and discarded
                //0.5 is safe in this case b/c we do not have grayscale values in between
                //clip(healthbarMask - 0.5);

                //float3 outColor = lerp(bgColor, healthbarColor, healthbarMask);

                //Can multipy healthbarMask by decimal to make colored part transparent as well
                //Do not multiply if you want color part to be opaque
                return float4(healthbarColor, healthbarMask * 0.5);
            }*/
            ENDCG
        }
    }
}
