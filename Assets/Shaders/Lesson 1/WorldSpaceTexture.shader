Shader "Unlit/WorldSpaceTexture"
{
    //Map texture to world space coords instead of uv coords. Texture is mapped to world space. 
    //If you move or scale object with this shader applied, the texture will always repeat in world space.
    //Bc it is top down, sides of object will get streched therefore it works well for flat stuff.
    //Common thing to use with terrain. You have vast stretches of terrain that blend better textures.
    //Sometimes it is easier to just use world space coord instead of having to update some UV coords on mesh
    //everytime you have to update the size of the terrain.
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
                float4 vertex : SV_POSITION; //Local space pos
                float3 worldPos : TEXCOORD1; //Instead of mapping in uv space, lets map in world space. 
                //Want to be able to send world coords from vertex shader to frag shader so we need this variable in interpolators.
                //Name worldPos b/c it is the worldPos of the pixel.
            };

            sampler2D _MainTex; //Need to define to be able to sample from a texture
            float4 _MainTex_ST; //optional, scaling (tiling) & offset. If you name it the same name as sampler and add _ST this will contain the scale offset.

            Interpolators vert (meshdata v)
            {
                Interpolators o;
                //Can also multiply by UNITY_MATRIX_M rather than unity_ObjectToWorld
                //mul func allows you to multiply vector by matrix
                //also has the advantage of by flipping the arugements you can transpose the matrix

                //When you do matrix mult where you transform a 3D vector, you normally pass a vector4 in
                //where last input having a 0 indicates it will be transformed as a vector or direction 
                //(orientation and scale only taken into account, not offset) and 1
                //transforms it as a position meaning offset will be taken into account
                //o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)); //transform from local space to world space
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex.xyz); //same as above, 1 is default, object to world, mul - Matrix multiply function. v.vertex - local space vertex position
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); //Scaling and offsetting UV coordinates. Optional, can just do o.uv = v.uv and texture will not be scaled and offset.
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz;
                //To debug, output as a color
                //return float4(topDownProjection, 0, 1);

                //fixed4 col = tex2D(_MainTex, i.uv); //tex2D means we will pick a color from the texture. Input is what sampler (or texture) do we want to use when sampling this and where do we want to get the color (uv coords).
                fixed4 col = tex2D(_MainTex, topDownProjection); //Don't need to use UVs. Instead we can use our top down projection which is our top down coordinates.
                return col;
            }
            ENDCG
        }
    }
}
