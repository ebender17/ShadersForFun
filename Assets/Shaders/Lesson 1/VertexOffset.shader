Shader "Unlit/VertexOffset"
{
     Properties
    {
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0, 1)) = 1
        _WaveAmp("Wave Amplitude", Range(0, 0.2)) = 0.1
    }
        SubShader
    {
        Tags { 
            "RenderType" = "Opaque" //tag to inform the render pipeline of what type this is, useful for post processing
            "Queue" = "Geometry" //changes the render order
        }
        Pass
        {

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"

            #define TAU 6.283138530718

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            float _WaveAmp;

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

                float wave = cos((v.uv0.y - _Time.y * 0.1) * TAU * 5);
                //float wave2 = cos((v.uv0.x - _Time.y * 0.1) * TAU * 5);

                //v.vertex.y = wave * wave2 * _WaveAmp; //If you want a more dynamic wave
                v.vertex.y = wave * _WaveAmp;

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
                float wave = cos((i.uv.y - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5; //range 0 to 1
                return wave;
            }
            ENDCG
        }
    }
}
