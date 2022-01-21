Shader "Unlit/SDFExample"
{
    Properties
    {
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

            struct interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            interpolators vert (meshdata v)
            {
                interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2 - 1; // change from 0 - 1 to -1 to 1, centered coodinate space ((0, 0) in center)
                return o;
            }

            float4 frag (interpolators i) : SV_Target
            {
                //distance from (0,0) to current coord we are rendering == length of uv vector
                //Made a signed distance field by subtracting a number to get negative distance values
                float dist = length(i.uv) - 0.3;


                //where ever signed distance field is negative we get black. Wherever it is positive we get white
                //step() is the same as a <= b, threshold check
                return step(0, dist);
                return float4(dist.xxx, 0);
            }
            ENDCG
        }
    }
}
