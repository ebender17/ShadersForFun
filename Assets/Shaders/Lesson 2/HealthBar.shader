Shader "Unlit/HealthBar"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0,1)) = 1
        _BorderSize ("Border Size", Range(0, 0.5)) = 0.1
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
            float _BorderSize;

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
                float2 coords = i.uv; //make seperate variable so we do not mess up coordinates for the rest of the code

                coords.x *= 8; //scale to 8 to make health bar coord sys uniform, 0 to 1 should look square

                //subtracts floored version of this coordinate, returns the fraction. In case it is continually increasing linearly, the uvs should repeat.
                //return float4(frac(coords), 0, 1);

                //want to 
                float2 pointOnLineSeg = float2( clamp( coords.x, 0.5, 7.5 ), 0.5);
                
                //distance between current coord and point on line segment
                //multiply by two so we have values from 0 to 1 at the very edge in all directions
                //subtract 1 to get 0 for every pixel that we want in the healthbar, pixels we want cut off will be values other than 0
                float sdf = distance(coords, pointOnLineSeg) * 2 - 1;
                
                //discard pixels outside sdf
                clip(-sdf);

                float borderSdf = sdf + _BorderSize;

                float pd = fwidth(borderSdf); //screen space partial derivative of the signed distance field, rate of change in screen space

                //float borderMask = step(0, -borderSdf); //before we implemented anti-aliasing

                float borderMask = 1 - saturate(borderSdf / pd); //we need to clamp with saturate and invert with minus one

                //return(sdf.xxx, 1);

                //return(borderSdf.xxx, 1);

                //return (borderMask.xxx, 1);

                float healthbarMask = _Health > i.uv.x;

                //We need x-axis to stay the same and y-axis to not.
                //x-axis - needs to have the same color going across health bar, therefore use _Health
                //y-axis - needs to change so we get the shading present in texture, therefore use y-axis uvs
                float3 healthbarColor = tex2D(_MainTex, float2(_Health, i.uv.y) );

                
                if(_Health < 0.2)
                {
                    //Add 1 to go from 0.9 to 1.1 instead of -0.9 and 0.1 bc we multiply healthbarColor by flash.
                    //If we multiply healthbarColor by 0 at some point, we will get black which we don't want.
                    float flash = cos(_Time.y * 4) * 0.25 + 1;
                    
                    //Only the health bar flashes, not the black background.
                    healthbarColor *= flash;
                }
                
                return float4(healthbarColor * healthbarMask * borderMask, 1);

            }

           
            ENDCG
        }
    }
}

// old healthbar
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