Shader "Unlit/ScrollingTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} //2D specifies 2D texture
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

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; //Need to define to be able to sample from a texture
            float4 _MainTex_ST; //optional, scaling (tiling) & offset. If you name it the same name as sampler and add _ST this will contain the scale offset.

            Interpolators vert (meshdata v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); //Scaling and offsetting UV coordinates. Optional, can just do o.uv = v.uv and texture will not be scaled and offset.
                o.uv.x += _Time.y * 0.1; //Gives scrolling effect. Adding to the UV coords meaning the texture is offset.
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv); //tex2D means we will pick a color from the texture. Input is what sampler (or texture) do we want to use when sampling this and where do we want to get the color (uv coords).
                return col;
            }
            ENDCG
        }
    }
}
