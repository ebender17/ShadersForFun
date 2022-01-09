Shader "Unlit/ColorGradient"
{
     Properties
    {
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0, 1)) = 1
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
            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

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

            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            float4 frag(Interpolators i) : SV_Target
            {
                //blend between two colors based on X UV coordinate
                float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x));
                
                //Cheak with frac func to see if we are extrapolating outside of 0 and 1. Repeating gradient shows we are extrapolated.
                //frac = value - floor(v)
                //t = frac(t);
                //return(t);

                float4 outColor = lerp(_ColorA, _ColorB, t);

                return outColor;
            }
            ENDCG
        }
    }
}
