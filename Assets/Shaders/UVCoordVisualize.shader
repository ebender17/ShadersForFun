Shader "Unlit/UVCoordVisualize"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert //Tells Complier what func is the vertex shader
            #pragma fragment frag //Tells Complier what func is the frag shader

            #include "UnityCG.cginc"

            //If you have a property, also need a variable to define along with it
            //Can acess properties in vertex and frag shader.
            float4 _Color;

            //automatically filled out by Unity
            //Per-vertex mesh data
            //All of the below are helpful when you need data from the mesh
            struct meshdata
            {
                float4 vertex : POSITION; //vertex position
                float3 normals : NORMAL; //normal direction of vertex
                float2 uv0 : TEXCOORD0; //uv coordinates. Very general & can be used for a lot of things. Often used to map textures to objects
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION; //clip space position
                float3 normal : TEXCOORD0; //Corresponds to one of the data streams coming from  vertex shader to frag
                float2 uv : TEXCOORD1; //TEXCOORD does not refer to UV channels in this case
            };

            //Vertex shader returns interpolators
            Interpolators vert (meshdata v)
            {
                Interpolators o; //o stands for output
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.normal = UnityObjectToWorldNormal(v.normals); 
                o.uv = v.uv0;
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                
                return float4(i.uv.yyy, 1);
            }
            ENDCG
        }
    }
}
