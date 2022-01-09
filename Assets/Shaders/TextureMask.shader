Shader "Unlit/TextureMask"
{
    //Blend better color red and texture. 
    //Grass is sample in world space.
    //Pattern is sample in UV space. When scaled pattern also scales but the grass will not scale.
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} //2D specifies 2D texture
        _Pattern ("Pattern", 2D) = "white" {}
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

            sampler2D _Pattern;

            Interpolators vert (meshdata v)
            {
                Interpolators o;
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex.xyz); 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float GetWave(float coord)
            {
                float wave = cos((coord - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                wave *= coord;
                return wave;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz;

                //fixed4 col = tex2D(_MainTex, i.uv); //tex2D means we will pick a color from the texture. Input is what sampler (or texture) do we want to use when sampling this and where do we want to get the color (uv coords).
                fixed4 col = tex2D(_MainTex, topDownProjection); //Don't need to use UVs. Instead we can use our top down projection which is our top down coordinates.
                float pattern = tex2D(_Pattern, i.uv);

                float4 finalColor = lerp(float4(1, 0, 0, 1), col, pattern);

                return finalColor;
            }
            ENDCG
        }
    }
}
