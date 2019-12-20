Shader "Stylized/Water"
{
    Properties
    {
        _SunSpecularExponent ("Sun Specular Exponent", float) = 1000
        [Header(Masks)]
        _DepthDensity ("Depth Density", Range(0.0, 1.0)) = 0.5
        _DistanceDensity ("Distance Density", Range(0.0, 1.0)) = 0.1

        [Header(Vertex Waves #1)]
        _Wave1Direction ("Direction", Range(0, 1)) = 0
        _Wave1Amplitude ("Amplitude", float) = 1
        _Wave1Wavelength ("Wavelength", float) = 1
        _Wave1Speed ("Speed", float) = 1

        [Header(Vertex Waves #2)]
        _Wave2Direction ("Direction", Range(0, 1)) = 0
        _Wave2Amplitude ("Amplitude", float) = 1
        _Wave2Wavelength ("Wavelength", float) = 1
        _Wave2Speed ("Speed", float) = 1
        
        [Header(Vertex Normal Recalculation)]
        _VertexNormalDelta ("dx", float) = 0.001

        [Header(Wave Normals)]
        [NoScaleOffset]
        _WaveNormalMap ("Normal Map", 2D) = "bump"{}
        _WaveNormalScale ("Scale", float) = 10.0
        _WaveNormalSpeed ("Speed", float) = 1.0

        
        [Header(Base Color)]
        _ShallowColor ("Shallow", Color) = (0.44, 0.95, 0.36, 1.0)
        _DeepColor ("Deep", Color) =  (0.0, 0.05, 0.19, 1.0)
        _FarColor ("Far", Color) = (0.04, 0.27, 0.75, 1.0)

        [Header(Subsurface Scattering)]
        _SSSColor ("Color", Color) = (1, 1, 1, 1)

        [Header(Foam)]
        _FoamTexture ("Texture", 2D) = "black"{}
        _FoamScale ("Scale", float) = 1.0
        _FoamNoiseScale ("Noise Contribution", Range(0.0, 1.0)) = 0.5
        _FoamSpeed ("Speed", float) = 1.0



        [Header(Shadows)]
        [Toggle(SAMPLE_SHADOWS)]
        _FancyShadows("Sample Shadows", int) = 0
        _MaxShadowDistance("Maximum Sample Distance", float) = 50.0

    }
    SubShader
    {
        LOD 100

        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        GrabPass
        {
            "_GrabTexture"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "Always" 
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog  // Make fog work.
            #pragma shader_feature SAMPLE_SHADOWS

            #include "UnityCG.cginc"
            #include "WaterUtilities.cginc"
            #include "ShadowUtilities.cginc"

            // Foam.
            sampler2D _FoamTexture;
            float _FoamScale;
            float _FoamNoiseScale;
            float _FoamSpeed;

            // Masks.
            float _DepthDensity;
            float _DistanceDensity;

            // Wave normal.
            float _VertexNormalDelta;

            // Wave 1.
            float _Wave1Direction;
            float _Wave1Amplitude;
            float _Wave1Wavelength;
            float _Wave1Speed;

            // Wave 2.
            float _Wave2Direction;
            float _Wave2Amplitude;
            float _Wave2Wavelength;
            float _Wave2Speed;

            // The grab pass texture from the previous pass.
            sampler2D _GrabTexture;

            // The depth texture.
            sampler2D _CameraDepthTexture;

            // Wave normals.
            sampler2D _WaveNormalMap;
            float _WaveNormalScale;
            float _WaveNormalSpeed;

            // Shadow mapping.
            uint _FancyShadows;
            float _MaxShadowDistance;
            sampler2D _MainDirectionalShadowMap;

            // Base colors.
            float3 _ShallowColor;
            float3 _DeepColor;
            float3 _FarColor;

            // SSS.
            float3 _SSSColor;

            float _SunSpecularExponent;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
                float4 grabPosition : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };

            // Returns the total wave height offset at the given world position,
            // based on the set wave properties.
            float GetWaveHeight(float2 worldPosition)
            {
                float2 dir1 = float2(cos(PI * _Wave1Direction), sin(PI * _Wave1Direction));
                float2 dir2 = float2(cos(PI * _Wave2Direction), sin(PI * _Wave2Direction));
                float wave1 = SimpleWave(worldPosition, dir1, _Wave1Wavelength, _Wave1Amplitude, _Wave1Speed);
                float wave2 = SimpleWave(worldPosition, dir2, _Wave2Wavelength, _Wave2Amplitude, _Wave2Speed);
                return wave1 + wave2;
            }

            // Approximates the normal of the wave at the given world position. The d
            // parameter controls the "sharpness" of the normal.
            float3x3 GetWaveTBN(float2 worldPosition, float d)
            {
                float waveHeight = GetWaveHeight(worldPosition);
                float waveHeightDX = GetWaveHeight(worldPosition - float2(d, 0));
                float waveHeightDZ = GetWaveHeight(worldPosition - float2(0, d));
                
                // Calculate the partial derivatives in the Z and X directions, which
                // are the tangent and binormal vectors respectively.
                float3 tangent = normalize(float3(0, waveHeight - waveHeightDZ, d));
                float3 binormal = normalize(float3(d, waveHeight - waveHeightDX, 0));

                // Cross the results to get the normal vector, and return the TBN matrix.
                // Note that the TBN matrix is orthogonal, i.e. TBN^-1 = TBN^T.
                // We exploit this fact to speed up the inversion process.
                float3 normal = normalize(cross(binormal, tangent));
                return transpose(float3x3(tangent, binormal, normal));
            }

            v2f vert (appdata v)
            {
                v2f o;

                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPosition.y += GetWaveHeight(o.worldPosition.xz);
                o.vertex = mul(UNITY_MATRIX_VP, float4(o.worldPosition, 1));

                // We don't want to offset the grab position by the wave height,
                // because we get nice refraction effects for free essentially.
                o.grabPosition = ComputeGrabScreenPos(mul(UNITY_MATRIX_VP, float4(mul(unity_ObjectToWorld, v.vertex).xyz, 1)));
                // o.grabPosition = ComputeGrabScreenPos(o.vertex);

                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Get the tangent to world matrix.
                float3x3 tangentToWorld = GetWaveTBN(i.worldPosition.xz, _VertexNormalDelta);

                // Calculate the view vector.
                float3 viewDirWS = normalize(i.worldPosition - _WorldSpaceCameraPos);

                // Sample the wave normal map and calculate the world-space normal for this fragment.
                float3 normalTS = MotionFourWayChaos(_WaveNormalMap, i.worldPosition.xz/_WaveNormalScale, _WaveNormalSpeed, true);
                float3 normalWS = mul(tangentToWorld, normalTS);


                // Calculate the position of this fragment in screen space to
                // use as uv's in screen-space texture look ups.
                float2 screenCoord = i.grabPosition.xy / i.grabPosition.w;

                // Sample the grab-pass and depth textures based on the screen coordinate
                // to get the frag color and depth of the fragment behind this one.
                float3 fragColor = tex2D(_GrabTexture, screenCoord.xy).rgb;
                float fragDepth = tex2D(_CameraDepthTexture, screenCoord.xy).x;

                // Calculate the distance the viewing ray travels underwater,
                // as well as the transmittance for that distance.
                float opticalDepth = abs(LinearEyeDepth(fragDepth) - LinearEyeDepth(i.vertex.z));
                float transmittance = exp(-_DepthDensity * opticalDepth);

                // Also calculate how far away the fragment is from the camera.
                float fragDist = length(i.worldPosition - _WorldSpaceCameraPos);
                float distMask = exp(-_DistanceDensity * fragDist);


                float shadow = 1.0;  // saturate(dot(-_WorldSpaceLightPos0.xyz, normalWS));
                #ifdef SAMPLE_SHADOWS
                    shadow *= GetLightVisibility(_MainDirectionalShadowMap, i.worldPosition, _MaxShadowDistance);
                #endif

                // Calculate the base color based on the transmittance and distance mask.
                float3 baseColor = fragColor * _ShallowColor;
                baseColor = lerp(_DeepColor, baseColor, transmittance * max(0.5, shadow));
                baseColor = lerp(_FarColor, baseColor, distMask);

                // Sample the reflection cubemap to get the reflections at this fragment.
                float3 reflection = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect(viewDirWS, normalWS));

                // Calculate the fresnel reflection coefficient and module the reflection by it and the distance mask.
                float fresnel = 0.0 + 1.0 * pow(1.0 + dot(normalWS, -viewDirWS), 5.0);
                reflection *= fresnel * distMask * shadow;

                // Calculate the subsurface scattering effect.
                float waveHeight = GetWaveHeight(i.worldPosition.xz);
                float3 sss = _SSSColor * saturate(waveHeight) * saturate(dot(_WorldSpaceLightPos0.xyz, viewDirWS));

                // Calculate the foam contribution.
                float3 foam = MotionFourWayChaos(_FoamTexture, i.worldPosition.xz/_FoamScale + _FoamNoiseScale*normalTS.xz, _FoamSpeed, false);
                foam *= max(waveHeight, 0.5) * max(shadow, 0.5) * distMask;

                // Calculate the sun specular reflection.
                float3 viewReflected = viewDirWS - 2*(dot(viewDirWS, normalWS))*normalWS;
                float vrDotL = saturate(dot(viewReflected, _WorldSpaceLightPos0));
                float sunSpec = round(saturate(pow(vrDotL, _SunSpecularExponent)));
                sunSpec *= shadow;

                // Calculate the sparkly bits.
                float sparkle = normalTS.x * normalTS.z;
                float3 tmp = MotionFourWayChaos(_WaveNormalMap, i.worldPosition.xz + normalTS.xz*2, 0*_WaveNormalSpeed/10, true);
                sparkle *= tmp.x*tmp.z*5;
                sparkle = saturate(round(pow(3*sparkle, 4))) * shadow;

                // Calculate edge foam.
                float height = waveHeight - viewDirWS.y*opticalDepth;
                height = 1-round(saturate(height*2.5));  // round(exp(-10*height));
                
                return (baseColor + reflection + sss + foam).xyzz + sunSpec + sparkle + height;

                


                



                
                // return reflection.xyzz;



                float4 color = shadow * (reflection).xyzz;  // float4(i.uv, 0, 1);
                // return color;
                

                // Calculate the length of the viewing ray from where it enters
                // the water to where it hits the fragment inside the water.
                
                // Apply fog.
                UNITY_APPLY_FOG(i.fogCoord, color);

                return color;
            }
            ENDCG
        }
    }
}
