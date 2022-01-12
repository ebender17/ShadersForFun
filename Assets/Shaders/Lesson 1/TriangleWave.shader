Shader "Unlit/TriangleWave"
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
        Tags { 
            "RenderType" = "Transparent" //tag to inform the render pipeline of what type this is, useful for post processing
            "Queue" = "Transparent" //changes the render order
        }
        Pass
        {
            //pass tags
            Cull Off
            ZWrite Off
            ZTest LEqual 
            Blend One One //additive

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"

            #define TAU 6.283138530718

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

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
                //Manual triangle wave
                //float t = abs(frac(i.uv.x * 5) * 2 - 1); //range 0 to 1

                //Can also use cos and sin
                //float v = cos(i.uv.x * TAU * 2); //range -1 to 1, multiply by TAU guarantees it will repeat perfectly.
                //float v = cos(i.uv.x * TAU * 5) * 0.5 + 0.5; //range 0 to 1

                //Diagnol pattern. As we go higher and higher on the y scale, we add more and more in one direction.
                //float xOffset = i.uv.y;
                //float v = cos((i.uv.x + xOffset) * TAU * 5) * 0.5 + 0.5; //range 0 to 1
                //return v;

                
                //Zig-zag pattern
                float xOffset = cos(i.uv.x * TAU * 8) * 0.01;
                float v = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5; //range 0 to 1
                //One easy way to make effect fade to black is multply by low value. If you multiply by 1, color does not change at all.
                // subtract by 1 to get fade in opposite direction
                v *= 1 - i.uv.y;
                
                float topBottomRemover = (abs(i.normal.y) < 0.999); //If the normal of the surface is pointing almost entirely up or down multiply by 0 and discard the fragment
                float waves = v * topBottomRemover;

                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);

                return gradient * waves;
            }
            ENDCG
        }
    }
}
