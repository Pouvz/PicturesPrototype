Shader "Custom/UnlitLightmap"
{
    Properties
    {
        _MainTex ("Color Texture", 2D) = "white" {}
        _ColorTint("Color Tint", Color) = (1,1,1,1)
        _NormalMap ("Normal Map", 2D) = "normal" {}
        _NormalScale ("Normal Scale", Range(0,1)) = 1
        _RealtimeDiffuse("Realtime Diffuse", Range(0,1)) = 1
        
        _Lightmap ("Lightmap Texture", 2D) = "gray" {}
        _lightmapOpacity ("Lightmap Opacity", Range(0,1)) = 1
        _LightmapExposure ("Lightmap Exposure", Float) = 0
        _LightmapSaturation ("Lightmap Saturation", Range(0,2)) = 1
        //_LightmapShadowColor("Lightmap ShadowColor", Color) = (1,1,1,1)
        
        }
    SubShader
    {
        // No culling or depth
        //Cull Off ZWrite Off ZTest Always
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fog

            //#include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Includes/ColorBlendModes.hlsl"





            
            //sampler2D _MainTex;
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            half4 _ColorTint;
            sampler2D _NormalMap;
            float _NormalScale;
            float _RealtimeDiffuse;
            
            // lightmap params
            sampler2D _Lightmap;
            float _lightmapOpacity;
            float _LightmapSaturation;
            float _LightmapExposure;
            //float4 _LightmapShadowColor;

            
            // from unity
            float3 _WorldSpaceLightPos0;
            
            
            struct Attributes
            {
                float4 positionOS      : POSITION;
                float3 normalOS        : NORMAL;
                float4 tangent         : TANGENT;
                float2 uv0             : TEXCOORD0;
                float2 uv1             : TEXCOORD1;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {

                float4 vertex   : SV_POSITION;
                
                float2 uv0      : TEXCOORD0;
                float2 uv1      : TEXCOORD1;
                float fogCoord : TEXCOORD2;

                float3 positionWS : TEXCOORD3;
                float3 normalWS   : NORMAL;
                //float3 tangent     : TANGENT;

                half3 tspace0 : TEXCOORD4; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD5; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD6; // tangent.z, bitangent.z, normal.z

                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float3 ApplyFog(half3 color, float fogCoord)
            {
                half fogFactor = 0;
                #if defined(_FOG_FRAGMENT)
                #if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
                    float viewZ = -fogCoord;
                    float nearToFarZ = max(viewZ - _ProjectionParams.y, 0);
                    fogFactor = ComputeFogFactorZ0ToFar(nearToFarZ);
                #endif
                #else
                    half fogFactor = fogCoord;
                #endif
                
                return MixFog(color, fogFactor);
                
            }

            float3 sampleNormal(sampler2D normalMapSampler,float2 uv, float amount)
            {
                float4 n = tex2D(normalMapSampler, uv);
                float3 noNormalMap = float3(0.0f,0.0f,1.0f);
                n.rgb = UnpackNormal(n);
                n.rgb = lerp(noNormalMap.rgb,n.rgb, amount);
                
                return normalize(n.rgb);
            }
            float3 NormalMapToWorldSpace(float3 normalMapTS,half3 tspace0,half3 tspace1,half3 tspace2)
            {
                float3 normalWS;
                normalWS.x = dot(tspace0, normalMapTS);
                normalWS.y = dot(tspace1, normalMapTS);
                normalWS.z = dot(tspace2, normalMapTS);

                return normalWS;
            }
            
            
            // Vertex Shader
            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;
                output.positionWS  = mul(unity_ObjectToWorld,input.positionOS);
                
                output.uv0 = input.uv0;
                output.uv1 = input.uv1;
                
                
                //
                half3 normalWS = normalize(mul(unity_ObjectToWorld,input.normalOS));
                output.normalWS = normalWS;

                // Tangent Space Stuff
                half3 tangentWS =  TransformObjectToWorldDir(input.tangent.xyz);
                half tangentSign = input.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(normalWS, tangentWS) * tangentSign;
                // output the tangent space matrix
                output.tspace0 = half3(tangentWS.x, wBitangent.x, normalWS.x);
                output.tspace1 = half3(tangentWS.y, wBitangent.y, normalWS.y);
                output.tspace2 = half3(tangentWS.z, wBitangent.z, normalWS.z);
                
                
                // Init fog
                #if defined(_FOG_FRAGMENT)
                output.fogCoord = vertexInput.positionVS.z;
                #else
                output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
                #endif
                
                return output;
            }
            
            // Fragment Shader
            float4 frag (Varyings input) : SV_Target 
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float4 outColor = float4(0,0,0,1);

                // normal
                float3 normalMapTS = sampleNormal(_NormalMap, input.uv0,_NormalScale).rgb;
                float3 normalWS = NormalMapToWorldSpace(normalMapTS,input.tspace0,input.tspace1,input.tspace2);

                
                
                
				//float4 Albedo = float4(0,0,0,1);
                float4 Albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0);
                Albedo *= _ColorTint;
                
                float4 Lightmap = tex2D(_Lightmap,input.uv1);
                Lightmap.rgb *= 2;
                

                
                Lightmap = Exposure(Lightmap,_LightmapExposure);
                Lightmap.rgb = DesaturateLinear(Lightmap.rgb,_LightmapSaturation);
                

                //float lightmapValue = DesaturateLinear(Lightmap,0);
                //lightmapValue = saturate(lightmapValue);
                //float4 lightmapTinted = Lightmap * _LightmapShadowColor;
                //Lightmap = lerp(Lightmap,lightmapTinted,1-lightmapValue);
                

                // Reltime Lighting 
                float NdotL = dot(normalWS,_WorldSpaceLightPos0);
                NdotL = saturate(NdotL);
                
                float3 diffuseShadow = unity_AmbientSky + NdotL;
                diffuseShadow = saturate(diffuseShadow);
                diffuseShadow = lerp(float3(1,1,1),diffuseShadow,_RealtimeDiffuse);

                Lightmap.rgb = lerp(float3(1,1,1),Lightmap.rgb,_lightmapOpacity);
                float3 Illumination = Lightmap.rgb * diffuseShadow.rgb;
                

                outColor.rgb = Albedo.rgb * Illumination.rgb;
                outColor.rgb = ApplyFog(outColor.rgb,input.fogCoord);

                return outColor;
            }
            
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
