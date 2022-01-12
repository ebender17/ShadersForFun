Shader "Unlit/TextureMaskBlend"
{
    //Blending between two textures.
    //Both textures are in world space. The pattern is only changing where they are blending not the mapping of the textures themselves bc they are sampled in world space.
    //Blend looks horrible. Would often use noise textures to modulate the blend.
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} //2D specifies 2D texture
        _Rock("Texture", 2D) = "white" {}
        _Pattern ("Pattern", 2D) = "white" {}
        _MipSampleLevel("MIP", Float) = 0 //0 is the highest level of detail where higher numbers are lower level of detail
        //Want 0 for clear image up close
        //Want higher number for less noisy image from far away
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

            #define TAU 6.28318630718

            struct meshdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION; //Local space pos
                float3 worldPos : TEXCOORD1; //Instead of mapping in uv space, lets map in world space. 
                //Want to be able to send world coords from vertex shader to frag shader so we need this variable in interpolators.
                //Name worldPos b/c it is the worldPos of the pixel.
            };

            sampler2D _MainTex; //Need to define to be able to sample from a texture
            sampler2D _Rock;
            sampler2D _Pattern;
            float _MipSampleLevel;

            Interpolators vert (meshdata v)
            {
                Interpolators o;
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex.xyz); 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz;

               
                fixed4 col = tex2Dlod(_MainTex, float4(topDownProjection, _MipSampleLevel.xx)); //float2 for final parameter if you want to do seperate for x and y coord (anisotropic) 
                fixed4 rock = tex2D(_Rock, topDownProjection);
                float pattern = tex2D(_Pattern, i.uv);

                float4 finalColor = lerp(rock, col, pattern);


                return finalColor;
            }
            ENDCG
        }
    }
}
