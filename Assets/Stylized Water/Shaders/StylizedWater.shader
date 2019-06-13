// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nature/StylizedWater"
{
	Properties
	{
		[Header(Global Variables)]_DistanceFade("Distance Fade", Float) = 40
		_DepthFade("Depth Fade", Float) = 20
		[HDR][Header(Base Color)]_Shallow("Shallow", Color) = (0.09448972,0.9691254,0.2277445,1)
		_Deep("Deep", Color) = (0,0.05,0.195,1)
		_Far("Far", Color) = (0,0.253,0.785,1)
		[Header(Edge Foam)][Toggle(_EDGEFOAMENABLED_ON)] _EdgeFoamEnabled("Edge Foam Enabled", Float) = 0
		_EdgeFoamDepth("Edge Foam Depth", Float) = 1
		_EdgeFoamNoiseScale("Edge Foam Noise Scale", Float) = 1
		_EdgeFoamColor("Edge Foam Color", Color) = (1,1,1,1)
		[Header(Sun Specular)][Toggle]_SunSpecularEnabled("Sun Specular Enabled", Float) = 1
		_SunSpecularExponent("Sun Specular Exponent", Float) = 2000
		_SunSpecularColor("Sun Specular Color", Color) = (1,1,1,1)
		[Header(Sparkle)][Toggle(_SPARKLEENABLED_ON)] _SparkleEnabled("Sparkle Enabled", Float) = 0
		[NoScaleOffset][Normal]_SparkleNormalMap("Sparkle Normal Map", 2D) = "bump" {}
		_SparkleScale("Sparkle Scale", Float) = 50
		_SparkleSpeed("Sparkle Speed", Float) = 0.75
		_SparkleExponent("Sparkle Exponent", Float) = 500
		_SparkleColor("Sparkle Color", Color) = (1,1,1,1)
		[Header(Wave Normal Map)][Toggle(_WAVENORMALENABLED_ON)] _WaveNormalEnabled("Wave Normal Enabled", Float) = 1
		[NoScaleOffset][Normal]_WaveNormal("Wave Normal", 2D) = "bump" {}
		_WaveNormalScale("Wave Normal  Scale", Float) = 50
		_WaveNormalSpeed("Wave Normal Speed", Float) = 0.25
		[Header(Refraction)]_RefractionContribution("Refraction Contribution", Range( 0 , 1)) = 1
		[Toggle]_ModulateRefractionbyDepth("Modulate Refraction by Depth", Float) = 1
		[Header(Foam)][Toggle(_FOAMENABLED_ON)] _FoamEnabled("Foam Enabled", Float) = 0
		[NoScaleOffset]_Foam("Foam", 2D) = "black" {}
		_FoamScale("Foam Scale", Float) = 1
		_FoamSpeed("Foam Speed", Float) = 1
		_FoamHeightOffset("Foam Height Offset", Float) = 0
		_FoamHeightMultiplier("Foam Height Multiplier", Float) = 1
		_FoamNoiseScale("Foam Noise Scale", Range( 0 , 1)) = 1
		[Header(Subsurface Scattering)][Toggle]_SSSEnabled("SSS Enabled", Float) = 1
		_SSSColor("SSS Color", Color) = (1,1,1,0)
		[Header(Reflection)][Toggle(_REFLECTIONENABLED_ON)] _ReflectionEnabled("Reflection Enabled", Float) = 1
		[NoScaleOffset]_ReflectionCubemap("Reflection Cubemap", CUBE) = "black" {}
		[Header(Wave 1)]_WaveDirection1("Wave Direction 1", Range( 0 , 1)) = 0
		_Wavelength1("Wavelength 1", Float) = 1
		_Speed1("Speed 1", Float) = 1
		_Amplitude1("Amplitude 1", Float) = 1
		[Header(Wave 2)]_WaveDirection2("Wave Direction 2", Range( 0 , 1)) = 0
		_Wavelength2("Wavelength 2", Float) = 1
		_Speed2("Speed 2", Float) = 1
		_Amplitude2("Amplitude 2", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma shader_feature _WAVENORMALENABLED_ON
		#pragma shader_feature _REFLECTIONENABLED_ON
		#pragma shader_feature _FOAMENABLED_ON
		#pragma shader_feature _SPARKLEENABLED_ON
		#pragma shader_feature _EDGEFOAMENABLED_ON
		#pragma surface surf Unlit alpha:fade keepalpha nodynlightmap nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			half eyeDepth;
			half vertexToFrag11_g100;
			INTERNAL_DATA
			float3 worldNormal;
			float3 worldRefl;
			half vertexToFrag11_g102;
			half vertexToFrag11_g104;
		};

		uniform half _Speed1;
		uniform half _WaveDirection1;
		uniform half _Wavelength1;
		uniform half _Amplitude1;
		uniform half _Speed2;
		uniform half _WaveDirection2;
		uniform half _Wavelength2;
		uniform half _Amplitude2;
		uniform half4 _Shallow;
		uniform sampler2D _GrabTexture;
		uniform half _RefractionContribution;
		uniform half _ModulateRefractionbyDepth;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform half _DepthFade;
		uniform sampler2D _WaveNormal;
		uniform half _WaveNormalSpeed;
		uniform half _WaveNormalScale;
		uniform half4 _Deep;
		uniform half4 _Far;
		uniform half _DistanceFade;
		uniform half _SSSEnabled;
		uniform half4 _SSSColor;
		uniform samplerCUBE _ReflectionCubemap;
		uniform half _FoamHeightMultiplier;
		uniform half _FoamHeightOffset;
		uniform sampler2D _Foam;
		uniform half _FoamSpeed;
		uniform half _FoamScale;
		uniform half _FoamNoiseScale;
		uniform half4 _SparkleColor;
		uniform sampler2D _SparkleNormalMap;
		uniform half _SparkleSpeed;
		uniform half _SparkleScale;
		uniform half _SparkleExponent;
		uniform half4 _SunSpecularColor;
		uniform half _SunSpecularEnabled;
		uniform half _SunSpecularExponent;
		uniform half4 _EdgeFoamColor;
		uniform half _EdgeFoamDepth;
		uniform half _EdgeFoamNoiseScale;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult20_g94 = (half2(ase_worldPos.x , ase_worldPos.z));
			float temp_output_42_0 = ( UNITY_PI * _WaveDirection1 );
			float2 appendResult44 = (half2(cos( temp_output_42_0 ) , sin( temp_output_42_0 )));
			float2 temp_output_2_0_g94 = appendResult44;
			float dotResult3_g94 = dot( appendResult20_g94 , temp_output_2_0_g94 );
			float temp_output_7_0_g94 = _Wavelength1;
			float temp_output_8_0_g94 = ( ( _Time.y * _Speed1 ) + ( ( dotResult3_g94 * UNITY_PI ) / temp_output_7_0_g94 ) );
			float temp_output_14_0_g94 = sin( temp_output_8_0_g94 );
			float temp_output_18_0_g94 = _Amplitude1;
			float3 appendResult126_g94 = (half3(0.0 , ( ( 1.0 - abs( temp_output_14_0_g94 ) ) * temp_output_18_0_g94 ) , 0.0));
			float2 appendResult20_g93 = (half2(ase_worldPos.x , ase_worldPos.z));
			float temp_output_115_0 = ( UNITY_PI * _WaveDirection2 );
			float2 appendResult117 = (half2(cos( temp_output_115_0 ) , sin( temp_output_115_0 )));
			float2 temp_output_2_0_g93 = appendResult117;
			float dotResult3_g93 = dot( appendResult20_g93 , temp_output_2_0_g93 );
			float temp_output_7_0_g93 = _Wavelength2;
			float temp_output_8_0_g93 = ( ( _Time.y * _Speed2 ) + ( ( dotResult3_g93 * UNITY_PI ) / temp_output_7_0_g93 ) );
			float temp_output_14_0_g93 = sin( temp_output_8_0_g93 );
			float temp_output_18_0_g93 = _Amplitude2;
			float3 appendResult126_g93 = (half3(0.0 , ( ( 1.0 - abs( temp_output_14_0_g93 ) ) * temp_output_18_0_g93 ) , 0.0));
			half3 VertexOffset191 = ( appendResult126_g94 + appendResult126_g93 );
			v.vertex.xyz += VertexOffset191;
			float2 break123_g94 = temp_output_2_0_g94;
			float3 appendResult124_g94 = (half3(break123_g94.x , 0.0 , break123_g94.y));
			float3 lerpResult125_g94 = lerp( float3( 0,1,0 ) , appendResult124_g94 , ( ( temp_output_18_0_g94 * 6.28318548202515 * temp_output_14_0_g94 * cos( temp_output_8_0_g94 ) ) / temp_output_7_0_g94 ));
			float2 break123_g93 = temp_output_2_0_g93;
			float3 appendResult124_g93 = (half3(break123_g93.x , 0.0 , break123_g93.y));
			float3 lerpResult125_g93 = lerp( float3( 0,1,0 ) , appendResult124_g93 , ( ( temp_output_18_0_g93 * 6.28318548202515 * temp_output_14_0_g93 * cos( temp_output_8_0_g93 ) ) / temp_output_7_0_g93 ));
			float3 normalizeResult189 = normalize( ( lerpResult125_g94 + lerpResult125_g93 ) );
			v.normal = normalizeResult189;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
			o.vertexToFrag11_g100 = ( 1.0 - exp2( -( distance( _WorldSpaceCameraPos , ase_worldPos ) / _DistanceFade ) ) );
			o.vertexToFrag11_g102 = ( 1.0 - exp2( -( distance( _WorldSpaceCameraPos , ase_worldPos ) / _DistanceFade ) ) );
			o.vertexToFrag11_g104 = ( 1.0 - exp2( -( distance( _WorldSpaceCameraPos , ase_worldPos ) / _DistanceFade ) ) );
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth532 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth532 = abs( ( screenDepth532 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthFade ) );
			float mulTime6_g48 = _Time.y * _WaveNormalSpeed;
			float Time23_g48 = mulTime6_g48;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult3_g47 = (half2(ase_worldPos.x , ase_worldPos.z));
			float2 Coordinates22_g48 = ( appendResult3_g47 / _WaveNormalScale );
			float2 panner14_g48 = ( Time23_g48 * half2( 0.1,0.1 ) + Coordinates22_g48);
			float2 panner15_g48 = ( Time23_g48 * half2( -0.1,-0.1 ) + ( Coordinates22_g48 + half2( 0.418,0.355 ) ));
			float2 panner16_g48 = ( Time23_g48 * half2( -0.1,0.1 ) + ( Coordinates22_g48 + half2( 0.865,0.148 ) ));
			float2 panner17_g48 = ( Time23_g48 * half2( 0.1,-0.1 ) + ( Coordinates22_g48 + half2( 0.651,0.752 ) ));
			#ifdef _WAVENORMALENABLED_ON
				float3 staticSwitch310 = ( ( UnpackNormal( tex2D( _WaveNormal, panner14_g48 ) ) + UnpackNormal( tex2D( _WaveNormal, panner15_g48 ) ) + UnpackNormal( tex2D( _WaveNormal, panner16_g48 ) ) + UnpackNormal( tex2D( _WaveNormal, panner17_g48 ) ) ) / 4.0 );
			#else
				float3 staticSwitch310 = half3(0,0,1);
			#endif
			float3 normalizeResult315 = normalize( staticSwitch310 );
			float temp_output_526_0 = ( _RefractionContribution * lerp((float)1,saturate( distanceDepth532 ),_ModulateRefractionbyDepth) * (normalizeResult315).x );
			float4 screenColor456 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( ase_grabScreenPosNorm + temp_output_526_0 ) ) );
			float eyeDepth3_g96 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ( ase_grabScreenPosNorm + temp_output_526_0 ) ))));
			float temp_output_5_0_g96 = _DepthFade;
			float4 lerpResult461 = lerp( ( _Shallow * screenColor456 ) , _Deep , saturate( ( ( eyeDepth3_g96 - i.eyeDepth ) / temp_output_5_0_g96 ) ));
			float temp_output_12_0_g100 = saturate( i.vertexToFrag11_g100 );
			float4 lerpResult465 = lerp( lerpResult461 , _Far , temp_output_12_0_g100);
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult418 = dot( ase_worldViewDir , -ase_worldlightDir );
			float2 appendResult20_g94 = (half2(ase_worldPos.x , ase_worldPos.z));
			float temp_output_42_0 = ( UNITY_PI * _WaveDirection1 );
			float2 appendResult44 = (half2(cos( temp_output_42_0 ) , sin( temp_output_42_0 )));
			float2 temp_output_2_0_g94 = appendResult44;
			float dotResult3_g94 = dot( appendResult20_g94 , temp_output_2_0_g94 );
			float temp_output_7_0_g94 = _Wavelength1;
			float temp_output_8_0_g94 = ( ( _Time.y * _Speed1 ) + ( ( dotResult3_g94 * UNITY_PI ) / temp_output_7_0_g94 ) );
			float temp_output_14_0_g94 = sin( temp_output_8_0_g94 );
			float temp_output_18_0_g94 = _Amplitude1;
			float3 appendResult126_g94 = (half3(0.0 , ( ( 1.0 - abs( temp_output_14_0_g94 ) ) * temp_output_18_0_g94 ) , 0.0));
			float2 appendResult20_g93 = (half2(ase_worldPos.x , ase_worldPos.z));
			float temp_output_115_0 = ( UNITY_PI * _WaveDirection2 );
			float2 appendResult117 = (half2(cos( temp_output_115_0 ) , sin( temp_output_115_0 )));
			float2 temp_output_2_0_g93 = appendResult117;
			float dotResult3_g93 = dot( appendResult20_g93 , temp_output_2_0_g93 );
			float temp_output_7_0_g93 = _Wavelength2;
			float temp_output_8_0_g93 = ( ( _Time.y * _Speed2 ) + ( ( dotResult3_g93 * UNITY_PI ) / temp_output_7_0_g93 ) );
			float temp_output_14_0_g93 = sin( temp_output_8_0_g93 );
			float temp_output_18_0_g93 = _Amplitude2;
			float3 appendResult126_g93 = (half3(0.0 , ( ( 1.0 - abs( temp_output_14_0_g93 ) ) * temp_output_18_0_g93 ) , 0.0));
			half3 VertexOffset191 = ( appendResult126_g94 + appendResult126_g93 );
			half3 ase_worldNormal = WorldNormalVector( i, half3( 0, 0, 1 ) );
			half3 ase_worldTangent = WorldNormalVector( i, half3( 1, 0, 0 ) );
			half3 ase_worldBitangent = WorldNormalVector( i, half3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV2_g97 = dot( mul(ase_tangentToWorldFast,normalizeResult315), ase_worldViewDir );
			float fresnelNode2_g97 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV2_g97, 5.0 ) );
			float temp_output_3_0_g97 = saturate( fresnelNode2_g97 );
			float fresnelNdotV2_g101 = dot( mul(ase_tangentToWorldFast,normalizeResult315), ase_worldViewDir );
			float fresnelNode2_g101 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV2_g101, 5.0 ) );
			float temp_output_3_0_g101 = saturate( fresnelNode2_g101 );
			float temp_output_12_0_g102 = saturate( i.vertexToFrag11_g102 );
			#ifdef _REFLECTIONENABLED_ON
				float4 staticSwitch412 = ( texCUBE( _ReflectionCubemap, WorldReflectionVector( i , normalizeResult315 ) ) * temp_output_3_0_g101 * ( 1.0 - temp_output_12_0_g102 ) );
			#else
				float4 staticSwitch412 = float4( 0,0,0,0 );
			#endif
			float mulTime6_g105 = _Time.y * _FoamSpeed;
			float Time23_g105 = mulTime6_g105;
			float2 appendResult3_g98 = (half2(ase_worldPos.x , ase_worldPos.z));
			float2 Coordinates22_g105 = ( half3( ( appendResult3_g98 / _FoamScale ) ,  0.0 ) + ( _FoamNoiseScale * normalizeResult315 ) ).xy;
			float2 panner14_g105 = ( Time23_g105 * half2( 0.1,0.1 ) + Coordinates22_g105);
			float2 panner15_g105 = ( Time23_g105 * half2( -0.1,-0.1 ) + ( Coordinates22_g105 + half2( 0.418,0.355 ) ));
			float2 panner16_g105 = ( Time23_g105 * half2( -0.1,0.1 ) + ( Coordinates22_g105 + half2( 0.865,0.148 ) ));
			float2 panner17_g105 = ( Time23_g105 * half2( 0.1,-0.1 ) + ( Coordinates22_g105 + half2( 0.651,0.752 ) ));
			float temp_output_12_0_g104 = saturate( i.vertexToFrag11_g104 );
			#ifdef _FOAMENABLED_ON
				float4 staticSwitch439 = ( saturate( ( _FoamHeightMultiplier * ( _FoamHeightOffset + (VertexOffset191).y ) ) ) * ( ( tex2D( _Foam, panner14_g105 ) + tex2D( _Foam, panner15_g105 ) + tex2D( _Foam, panner16_g105 ) + tex2D( _Foam, panner17_g105 ) ) / 4.0 ) * ( 1.0 - temp_output_12_0_g104 ) );
			#else
				float4 staticSwitch439 = float4( 0,0,0,0 );
			#endif
			float mulTime22_g91 = _Time.y * _SparkleSpeed;
			float2 appendResult3_g90 = (half2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_594_0 = ( appendResult3_g90 / _SparkleScale );
			float2 temp_output_17_0_g91 = temp_output_594_0;
			float4 break16_g91 = float4( 1,2,3,4 );
			float2 panner6_g91 = ( mulTime22_g91 * float2( 0.1,0 ) + ( temp_output_17_0_g91 * break16_g91.x ));
			float2 panner7_g91 = ( mulTime22_g91 * float2( -0.1,0 ) + ( temp_output_17_0_g91 * break16_g91.y ));
			float3 appendResult24_g91 = (half3(UnpackNormal( tex2D( _SparkleNormalMap, panner6_g91 ) ).r , UnpackNormal( tex2D( _SparkleNormalMap, panner7_g91 ) ).g , 1.0));
			float2 panner5_g91 = ( mulTime22_g91 * float2( 0,0.1 ) + ( temp_output_17_0_g91 * break16_g91.z ));
			float2 panner8_g91 = ( mulTime22_g91 * float2( 0,-0.1 ) + ( temp_output_17_0_g91 * break16_g91.w ));
			float3 appendResult25_g91 = (half3(UnpackNormal( tex2D( _SparkleNormalMap, panner5_g91 ) ).r , UnpackNormal( tex2D( _SparkleNormalMap, panner8_g91 ) ).g , 1.0));
			float3 temp_output_571_0 = BlendNormals( appendResult24_g91 , appendResult25_g91 );
			float3 normalizeResult578 = normalize( temp_output_571_0 );
			float mulTime22_g92 = _Time.y * _SparkleSpeed;
			float2 temp_output_17_0_g92 = temp_output_594_0;
			float4 break16_g92 = float4( 1,0.5,2.5,2 );
			float2 panner6_g92 = ( mulTime22_g92 * float2( 0.1,0 ) + ( temp_output_17_0_g92 * break16_g92.x ));
			float2 panner7_g92 = ( mulTime22_g92 * float2( -0.1,0 ) + ( temp_output_17_0_g92 * break16_g92.y ));
			float3 appendResult24_g92 = (half3(UnpackNormal( tex2D( _SparkleNormalMap, panner6_g92 ) ).r , UnpackNormal( tex2D( _SparkleNormalMap, panner7_g92 ) ).g , 1.0));
			float2 panner5_g92 = ( mulTime22_g92 * float2( 0,0.1 ) + ( temp_output_17_0_g92 * break16_g92.z ));
			float2 panner8_g92 = ( mulTime22_g92 * float2( 0,-0.1 ) + ( temp_output_17_0_g92 * break16_g92.w ));
			float3 appendResult25_g92 = (half3(UnpackNormal( tex2D( _SparkleNormalMap, panner5_g92 ) ).r , UnpackNormal( tex2D( _SparkleNormalMap, panner8_g92 ) ).g , 1.0));
			float3 temp_output_572_0 = BlendNormals( appendResult24_g92 , appendResult25_g92 );
			float3 normalizeResult580 = normalize( temp_output_572_0 );
			float dotResult582 = dot( normalizeResult578 , normalizeResult580 );
			float dotResult575 = dot( (temp_output_571_0).x , (temp_output_572_0).x );
			float temp_output_577_0 = sqrt( saturate( dotResult575 ) );
			#ifdef _SPARKLEENABLED_ON
				float staticSwitch615 = ceil( saturate( pow( ( dotResult582 * saturate( ( temp_output_577_0 + temp_output_577_0 + temp_output_577_0 ) ) ) , _SparkleExponent ) ) );
			#else
				float staticSwitch615 = 0.0;
			#endif
			float4 lerpResult637 = lerp( ( ( ( lerpResult465 + lerp(float4( 0,0,0,0 ),( _SSSColor * ( saturate( dotResult418 ) * saturate( (VertexOffset191).y ) * temp_output_3_0_g97 ) ),_SSSEnabled) ) + staticSwitch412 ) + staticSwitch439 ) , _SparkleColor , staticSwitch615);
			float dotResult623 = dot( ase_worldlightDir , normalize( WorldReflectionVector( i , normalizeResult315 ) ) );
			float4 lerpResult639 = lerp( lerpResult637 , _SunSpecularColor , lerp(0.0,round( saturate( pow( (0.0 + (dotResult623 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , _SunSpecularExponent ) ) ),_SunSpecularEnabled));
			float fresnelNdotV2_g95 = dot( mul(ase_tangentToWorldFast,normalizeResult315), ase_worldViewDir );
			float fresnelNode2_g95 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV2_g95, 5.0 ) );
			float temp_output_3_0_g95 = saturate( fresnelNode2_g95 );
			float screenDepth492 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth492 = abs( ( screenDepth492 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( _EdgeFoamDepth * (0.25 + (temp_output_3_0_g95 - 0.0) * (1.0 - 0.25) / (1.0 - 0.0)) ) ) );
			float2 appendResult3_g99 = (half2(ase_worldPos.x , ase_worldPos.z));
			float3 appendResult503 = (half3(( appendResult3_g99 / _EdgeFoamNoiseScale ) , _Time.y));
			float simplePerlin3D505 = snoise( appendResult503 );
			#ifdef _EDGEFOAMENABLED_ON
				float staticSwitch510 = round( ( ( 1.0 - saturate( distanceDepth492 ) ) * (0.25 + (( 1.0 - simplePerlin3D505 ) - 0.0) * (1.0 - 0.25) / (1.0 - 0.0)) ) );
			#else
				float staticSwitch510 = 0.0;
			#endif
			float4 lerpResult641 = lerp( lerpResult639 , _EdgeFoamColor , staticSwitch510);
			o.Emission = lerpResult641.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
276;73;1289;632;-965.8765;-424.2219;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;313;-572.6531,1164.608;Float;False;1345.618;400.8902;;8;315;310;305;316;309;307;306;308;Waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;308;-522.6531,1214.608;Float;False;Property;_WaveNormalScale;Wave Normal  Scale;20;0;Create;True;0;0;False;0;50;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;194;14520.27,580.4026;Float;False;1626.573;937.3202;;24;191;189;188;185;238;237;118;47;44;46;117;119;45;113;40;112;41;116;115;42;50;114;39;111;Vertex Waves;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;306;-275.5134,1373.977;Float;True;Property;_WaveNormal;Wave Normal;19;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;307;-299.7603,1218.796;Float;False;WorldPositionXZ;-1;;47;409d61e1d315a484388d8ae966642b06;0;1;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;309;-268.6243,1294.848;Float;False;Property;_WaveNormalSpeed;Wave Normal Speed;21;0;Create;True;0;0;False;0;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;111;14655.02,1098.932;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;14564.3,1182.443;Float;False;Property;_WaveDirection2;Wave Direction 2;39;0;Create;True;0;0;False;1;Header(Wave 2);0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;50;14655.6,642.9384;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;14564.88,726.4482;Float;False;Property;_WaveDirection1;Wave Direction 1;35;0;Create;True;0;0;False;1;Header(Wave 1);0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;305;-21.06589,1276.944;Float;False;MotionFourWayChaosNormal;45;;48;ac538d4bcae1f4cdfb4426dbd82dd2d1;0;3;11;FLOAT2;0,0;False;10;FLOAT;1;False;7;SAMPLER2D;;False;1;FLOAT3;21
Node;AmplifyShaderEditor.Vector3Node;316;117.6258,1396.728;Float;False;Constant;_up;up;20;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;614;7687.367,530.9519;Float;False;3001.719;528.925;;24;615;568;596;586;585;583;584;581;582;580;579;578;577;576;575;574;573;572;571;570;593;564;594;561;Sparkles;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;14843.52,1131.006;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;310;322.2365,1248.461;Float;False;Property;_WaveNormalEnabled;Wave Normal Enabled;18;0;Create;True;0;0;False;1;Header(Wave Normal Map);0;1;1;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;14844.1,675.0123;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;7737.367,627.9012;Float;False;Property;_SparkleScale;Sparkle Scale;14;0;Create;True;0;0;False;0;50;75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;112;15005.18,1104.064;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;594;7925.366,634.188;Float;False;WorldPositionXZ;-1;;90;409d61e1d315a484388d8ae966642b06;0;1;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;315;609.5892,1254.719;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CosOpNode;40;15005.76,648.0704;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;468;1037.143,400.5363;Float;False;2050.288;690.6732;;18;539;533;532;465;453;461;466;529;454;462;456;455;523;526;457;525;527;543;Base Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SinOpNode;41;15004.53,725.2243;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;272;878.9215,1141.65;Float;False;Property;_DepthFade;Depth Fade;1;0;Create;True;0;0;True;0;20;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;568;7949.761,853.6235;Float;True;Property;_SparkleNormalMap;Sparkle Normal Map;13;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;b87c6510a4b3945a197eabf8b0d60278;b87c6510a4b3945a197eabf8b0d60278;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SinOpNode;116;15003.95,1181.218;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;564;7986.454,738.7034;Float;False;Property;_SparkleSpeed;Sparkle Speed;15;0;Create;True;0;0;False;0;0.75;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;15134.72,670.0422;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;570;8323.861,791.6633;Float;False;MotionFourWaySparkle;-1;;92;79633fb22518042b282ba70323d1bf02;0;4;17;FLOAT2;0,0;False;15;FLOAT4;1,0.5,2.5,2;False;18;FLOAT;1;False;19;SAMPLER2D;;False;2;FLOAT3;0;FLOAT3;13
Node;AmplifyShaderEditor.DynamicAppendNode;117;15134.14,1126.036;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;45;15104.82,801.3411;Float;False;Property;_Wavelength1;Wavelength 1;36;0;Create;True;0;0;False;0;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;15126.34,1341.836;Float;False;Property;_Speed2;Speed 2;41;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;15117.24,1423.735;Float;False;Property;_Amplitude2;Amplitude 2;42;0;Create;True;0;0;False;0;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;593;8318.554,634.7774;Float;False;MotionFourWaySparkle;-1;;91;79633fb22518042b282ba70323d1bf02;0;4;17;FLOAT2;0,0;False;15;FLOAT4;1,2,3,4;False;18;FLOAT;1;False;19;SAMPLER2D;;False;2;FLOAT3;0;FLOAT3;13
Node;AmplifyShaderEditor.RangedFloatNode;118;15104.24,1257.335;Float;False;Property;_Wavelength2;Wavelength 2;40;0;Create;True;0;0;False;0;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;643;1229.591,1255.128;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;46;15126.92,885.8423;Float;False;Property;_Speed1;Speed 1;37;0;Create;True;0;0;False;0;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;532;1103.105,836.6233;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;15117.82,967.7421;Float;False;Property;_Amplitude1;Amplitude 1;38;0;Create;True;0;0;False;0;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;644;3351.049,1256.094;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;571;8624.178,633.3272;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;237;15425.94,1222.664;Float;False;SimpleWave;-1;;93;3e1dedc78dc29ed4fa10223c11d7f104;0;4;2;FLOAT2;0,0;False;7;FLOAT;0;False;11;FLOAT;0;False;18;FLOAT;0;False;2;FLOAT3;0;FLOAT3;76
Node;AmplifyShaderEditor.FunctionNode;238;15375.98,811.6412;Float;False;SimpleWave;-1;;94;3e1dedc78dc29ed4fa10223c11d7f104;0;4;2;FLOAT2;0,0;False;7;FLOAT;0;False;11;FLOAT;0;False;18;FLOAT;0;False;2;FLOAT3;0;FLOAT3;76
Node;AmplifyShaderEditor.BlendNormalsNode;572;8634.706,792.1602;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;533;1351.173,836.4014;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;539;1336.006,754.0694;Float;False;Constant;_refrac_one;refrac_one;35;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.SwizzleNode;573;8922.481,846.8635;Float;False;FLOAT;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;574;8928.471,755.0276;Float;False;FLOAT;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;432;3146.306,622.306;Float;False;1462.215;468.4396;;13;420;421;419;418;422;428;425;424;426;430;423;429;544;SSS;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;527;1538.068,704.7197;Float;False;Property;_RefractionContribution;Refraction Contribution;22;0;Create;True;0;0;False;1;Header(Refraction);1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;645;4593.659,1255.269;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;543;1514.029,782.6942;Float;False;Property;_ModulateRefractionbyDepth;Modulate Refraction by Depth;23;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;525;1664.764,894.2826;Float;False;FLOAT;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;185;15763.83,808.93;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;526;1853.829,765.9608;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;646;6158.89,1255.845;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition;457;1752.445,530.3832;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;420;3196.306,822.7112;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;575;9076.21,794.9561;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;191;15894.88,803.6402;Half;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;523;2009.356,634.8578;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NegateNode;421;3462.306,822.7112;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;647;10676.83,1254.764;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;419;3417.657,672.3063;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;424;3447.306,888.7114;Float;False;191;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;452;6090.284,431.0132;Float;False;1553.646;640.8525;;18;445;447;441;443;446;444;442;480;434;450;451;438;437;448;435;433;439;440;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;576;9199.985,794.9561;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;456;2137.306,630.3834;Float;False;Global;_GrabScreen0;Grab Screen 0;35;0;Create;True;0;0;False;0;Object;-1;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;648;12241.46,1256.695;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;577;9355.708,794.9561;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;441;6134.018,579.5541;Float;False;191;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;511;12430.18,589.9163;Float;False;2025.183;460.3971;;17;509;506;505;508;503;502;504;501;497;510;491;507;489;495;492;500;488;Edge Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;418;3663.009,743.8116;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;455;2095.883,453.2787;Float;False;Property;_Shallow;Shallow;2;1;[HDR];Create;True;0;0;False;1;Header(Base Color);0.09448972,0.9691254,0.2277445,1;0.4448565,0.9156269,0.6611565,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;425;3661.307,887.7114;Float;False;FLOAT;1;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;537;2050.704,1148.714;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;454;2325.552,668.5792;Float;False;Property;_Deep;Deep;3;0;Create;True;0;0;False;0;0,0.05,0.195,1;0,0.01246505,0.1226415,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;426;3718.307,977.7114;Float;False;FresnelMask;-1;;97;d95d9758f901b054ba3afd1a2c4eaa23;0;1;1;FLOAT3;0,0,1;False;2;FLOAT;0;FLOAT;5
Node;AmplifyShaderEditor.FunctionNode;529;2268.145,849.9016;Float;False;DepthMask;-1;;96;8fcb58851a628ea4d851fc610a3c97e6;0;2;5;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;422;3809.307,743.7112;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;580;8919.347,658.3909;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;259;2304.367,1128.394;Float;False;Property;_DistanceFade;Distance Fade;0;0;Create;True;0;0;True;1;Header(Global Variables);40;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;508;12641.14,881.7755;Float;False;Property;_EdgeFoamNoiseScale;Edge Foam Noise Scale;7;0;Create;True;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;417;4686.356,607.8058;Float;False;1360.723;472.8696;;6;412;416;482;414;415;411;Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;462;2398.985,527.166;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;635;10751.19,679.1948;Float;False;1647.233;375.371;;9;622;621;623;624;625;626;629;634;636;Sun Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;428;3812.307,892.7114;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;497;12704.52,717.068;Float;False;FresnelMask;-1;;95;d95d9758f901b054ba3afd1a2c4eaa23;0;1;1;FLOAT3;0,0,1;False;2;FLOAT;0;FLOAT;5
Node;AmplifyShaderEditor.NormalizeNode;578;8920.001,580.9517;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;579;9489.469,772.9951;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;444;6258.688,494.8017;Float;False;Property;_FoamHeightOffset;Foam Height Offset;28;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;442;6339.033,579.5541;Float;False;FLOAT;1;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;451;6218.91,745.6624;Float;False;Property;_FoamNoiseScale;Foam Noise Scale;30;0;Create;True;0;0;False;0;1;0.317;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;438;6229.33,663.0875;Float;False;Property;_FoamScale;Foam Scale;26;0;Create;True;0;0;False;0;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;453;2609.082,781.5996;Float;False;Property;_Far;Far;4;0;Create;True;0;0;False;0;0,0.253,0.785,1;0.1186365,0.479986,0.8113208,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;502;12893.19,887.0536;Float;False;WorldPositionXZ;-1;;99;409d61e1d315a484388d8ae966642b06;0;1;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;504;12963.4,968.9541;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;581;9629.219,770.9988;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;466;2576.343,970.5638;Float;False;DistanceMask;-1;;100;7dbb56e5096e6ea498540af469ddbdd2;0;1;21;FLOAT;40;False;3;FLOAT;0;FLOAT;1;FLOAT;23
Node;AmplifyShaderEditor.WorldReflectionVector;622;11043.57,875.5659;Float;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;430;3976.832,684.948;Float;False;Property;_SSSColor;SSS Color;32;0;Create;True;0;0;False;0;1,1,1,0;0.4739727,0.8862745,0.172549,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;535;5158.843,1129.929;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;423;4043.57,865.2662;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;501;12955.3,717.068;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.25;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;582;9096.507,605.1629;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;411;5039.294,686.3401;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;488;12930.44,637.2123;Float;False;Property;_EdgeFoamDepth;Edge Foam Depth;6;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;461;2672.292,649.2822;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;450;6507.699,749.8821;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;443;6604.815,563.7395;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;446;6480.792,480.5259;Float;False;Property;_FoamHeightMultiplier;Foam Height Multiplier;29;0;Create;True;0;0;False;0;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;437;6399.748,667.9936;Float;False;WorldPositionXZ;-1;;98;409d61e1d315a484388d8ae966642b06;0;1;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;621;11010.49,729.1948;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;584;9626.389,846.2102;Float;False;Property;_SparkleExponent;Sparkle Exponent;16;0;Create;True;0;0;False;0;500;20000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;500;13163.51,667.1049;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;414;5283.546,657.8062;Float;True;Property;_ReflectionCubemap;Reflection Cubemap;34;1;[NoScaleOffset];Create;True;0;0;False;0;aff1efcdcea9940b89e860cfa43fc9d5;189043a94c8142c45bea2915b3f8d8be;True;0;False;black;LockedToCube;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;503;13154.88,916.1494;Float;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;583;9780.975,607.2869;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;433;6434.402,852.4656;Float;True;Property;_Foam;Foam;25;1;[NoScaleOffset];Create;True;0;0;False;0;None;581fcfd543a4445829bb923bace720da;False;black;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;4208.868,775.9014;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;445;6755.81,540.5645;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;465;2913.868,761.2224;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;448;6679.061,693.7422;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;435;6650.339,828.2849;Float;False;Property;_FoamSpeed;Foam Speed;27;0;Create;True;0;0;False;0;1;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;623;11276.13,801.046;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;482;5323.042,948.0746;Float;False;DistanceMask;-1;;102;7dbb56e5096e6ea498540af469ddbdd2;0;1;21;FLOAT;40;False;3;FLOAT;0;FLOAT;1;FLOAT;23
Node;AmplifyShaderEditor.FunctionNode;415;5329.712,849.0796;Float;False;FresnelMask;-1;;101;d95d9758f901b054ba3afd1a2c4eaa23;0;1;1;FLOAT3;0,0,1;False;2;FLOAT;0;FLOAT;5
Node;AmplifyShaderEditor.RelayNode;536;6597.045,1133.429;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;447;6958.694,694.9586;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;505;13312.18,910.9494;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;416;5617.712,758.0796;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RelayNode;514;3732.729,233.9515;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;624;11350.26,919.6537;Float;False;Property;_SunSpecularExponent;Sun Specular Exponent;10;0;Create;True;0;0;False;0;2000;3500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;585;9961.972,828.9856;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;480;6862.242,930.1284;Float;False;DistanceMask;-1;;104;7dbb56e5096e6ea498540af469ddbdd2;0;1;21;FLOAT;40;False;3;FLOAT;0;FLOAT;1;FLOAT;23
Node;AmplifyShaderEditor.FunctionNode;636;11406.98,800.6796;Float;False;DotRemap01;-1;;103;52c4b89812f1bca4aafc7e2322852b11;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;492;13302.18,646.5548;Float;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;544;4369.231,745.9548;Float;False;Property;_SSSEnabled;SSS Enabled;31;0;Create;True;0;0;False;1;Header(Subsurface Scattering);1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;434;6854.209,810.3892;Float;False;MotionFourWayChaos;43;;105;902e36c7d4587450ba631081c4a35c1b;0;3;11;FLOAT2;0,0;False;10;FLOAT;1;False;7;SAMPLER2D;;False;1;COLOR;21
Node;AmplifyShaderEditor.OneMinusNode;509;13521.87,803.7821;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;440;7161.915,786.3701;Float;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;586;10110.31,830.6526;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;495;13551.37,644.7533;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;412;5758.803,729.9792;Float;False;Property;_ReflectionEnabled;Reflection Enabled;33;0;Create;True;0;0;False;1;Header(Reflection);0;1;1;True;;Toggle;2;Key0;Key1;Create;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;479;5369.85,242.6405;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;625;11633.46,853.0268;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;506;13685.28,803.0497;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.25;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;489;13699.21,644.6555;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;596;10272.67,830.5549;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;485;6574.777,239.5449;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;626;11788.97,852.9648;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;439;7324.522,757.777;Float;False;Property;_FoamEnabled;Foam Enabled;24;0;Create;True;0;0;False;1;Header(Foam);0;0;1;True;;Toggle;2;Key0;Key1;Create;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;13896.65,750.3928;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;615;10417.91,802.0186;Float;False;Property;_SparkleEnabled;Sparkle Enabled;12;0;Create;True;0;0;False;1;Header(Sparkle);0;0;1;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;629;11939.4,852.8759;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;638;10489.6,311.0777;Float;False;Property;_SparkleColor;Sparkle Color;17;0;Create;True;0;0;False;0;1,1,1,1;0.5492168,0.9622642,0.8175886,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;486;8525.636,241.9366;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;634;12084.59,824.5255;Float;False;Property;_SunSpecularEnabled;Sun Specular Enabled;9;0;Create;True;0;0;False;1;Header(Sun Specular);1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;491;14042.37,751.5715;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;637;10795.64,242.7801;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;640;12179.33,318.24;Float;False;Property;_SunSpecularColor;Sun Specular Color;11;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;188;15806.8,1221.31;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;510;14178.08,724.4463;Float;False;Property;_EdgeFoamEnabled;Edge Foam Enabled;5;0;Create;True;0;0;False;1;Header(Edge Foam);0;0;1;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;639;12508.26,242.6996;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;642;14259.8,321.8405;Float;False;Property;_EdgeFoamColor;Edge Foam Color;8;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;189;15948.68,1221.204;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;641;14606.91,244.281;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;247;16341.77,203.6183;Half;False;True;2;Half;ASEMaterialInspector;0;0;Unlit;Nature/StylizedWater;False;False;False;False;False;False;False;True;True;False;False;False;False;False;True;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;307;1;308;0
WireConnection;305;11;307;0
WireConnection;305;10;309;0
WireConnection;305;7;306;0
WireConnection;115;0;111;0
WireConnection;115;1;114;0
WireConnection;310;1;316;0
WireConnection;310;0;305;21
WireConnection;42;0;50;0
WireConnection;42;1;39;0
WireConnection;112;0;115;0
WireConnection;594;1;561;0
WireConnection;315;0;310;0
WireConnection;40;0;42;0
WireConnection;41;0;42;0
WireConnection;116;0;115;0
WireConnection;44;0;40;0
WireConnection;44;1;41;0
WireConnection;570;17;594;0
WireConnection;570;18;564;0
WireConnection;570;19;568;0
WireConnection;117;0;112;0
WireConnection;117;1;116;0
WireConnection;593;17;594;0
WireConnection;593;18;564;0
WireConnection;593;19;568;0
WireConnection;643;0;315;0
WireConnection;532;0;272;0
WireConnection;644;0;643;0
WireConnection;571;0;593;0
WireConnection;571;1;593;13
WireConnection;237;2;117;0
WireConnection;237;7;118;0
WireConnection;237;11;119;0
WireConnection;237;18;113;0
WireConnection;238;2;44;0
WireConnection;238;7;45;0
WireConnection;238;11;46;0
WireConnection;238;18;47;0
WireConnection;572;0;570;0
WireConnection;572;1;570;13
WireConnection;533;0;532;0
WireConnection;573;0;572;0
WireConnection;574;0;571;0
WireConnection;645;0;644;0
WireConnection;543;0;539;0
WireConnection;543;1;533;0
WireConnection;525;0;643;0
WireConnection;185;0;238;0
WireConnection;185;1;237;0
WireConnection;526;0;527;0
WireConnection;526;1;543;0
WireConnection;526;2;525;0
WireConnection;646;0;645;0
WireConnection;575;0;574;0
WireConnection;575;1;573;0
WireConnection;191;0;185;0
WireConnection;523;0;457;0
WireConnection;523;1;526;0
WireConnection;421;0;420;0
WireConnection;647;0;646;0
WireConnection;576;0;575;0
WireConnection;456;0;523;0
WireConnection;648;0;647;0
WireConnection;577;0;576;0
WireConnection;418;0;419;0
WireConnection;418;1;421;0
WireConnection;425;0;424;0
WireConnection;537;0;272;0
WireConnection;426;1;644;0
WireConnection;529;5;537;0
WireConnection;529;1;526;0
WireConnection;422;0;418;0
WireConnection;580;0;572;0
WireConnection;462;0;455;0
WireConnection;462;1;456;0
WireConnection;428;0;425;0
WireConnection;497;1;648;0
WireConnection;578;0;571;0
WireConnection;579;0;577;0
WireConnection;579;1;577;0
WireConnection;579;2;577;0
WireConnection;442;0;441;0
WireConnection;502;1;508;0
WireConnection;581;0;579;0
WireConnection;466;21;259;0
WireConnection;622;0;647;0
WireConnection;535;0;259;0
WireConnection;423;0;422;0
WireConnection;423;1;428;0
WireConnection;423;2;426;0
WireConnection;501;0;497;0
WireConnection;582;0;578;0
WireConnection;582;1;580;0
WireConnection;411;0;645;0
WireConnection;461;0;462;0
WireConnection;461;1;454;0
WireConnection;461;2;529;0
WireConnection;450;0;451;0
WireConnection;450;1;646;0
WireConnection;443;0;444;0
WireConnection;443;1;442;0
WireConnection;437;1;438;0
WireConnection;500;0;488;0
WireConnection;500;1;501;0
WireConnection;414;1;411;0
WireConnection;503;0;502;0
WireConnection;503;2;504;0
WireConnection;583;0;582;0
WireConnection;583;1;581;0
WireConnection;429;0;430;0
WireConnection;429;1;423;0
WireConnection;445;0;446;0
WireConnection;445;1;443;0
WireConnection;465;0;461;0
WireConnection;465;1;453;0
WireConnection;465;2;466;0
WireConnection;448;0;437;0
WireConnection;448;1;450;0
WireConnection;623;0;621;0
WireConnection;623;1;622;0
WireConnection;482;21;535;0
WireConnection;415;1;645;0
WireConnection;536;0;535;0
WireConnection;447;0;445;0
WireConnection;505;0;503;0
WireConnection;416;0;414;0
WireConnection;416;1;415;0
WireConnection;416;2;482;1
WireConnection;514;0;465;0
WireConnection;585;0;583;0
WireConnection;585;1;584;0
WireConnection;480;21;536;0
WireConnection;636;1;623;0
WireConnection;492;0;500;0
WireConnection;544;1;429;0
WireConnection;434;11;448;0
WireConnection;434;10;435;0
WireConnection;434;7;433;0
WireConnection;509;0;505;0
WireConnection;440;0;447;0
WireConnection;440;1;434;21
WireConnection;440;2;480;1
WireConnection;586;0;585;0
WireConnection;495;0;492;0
WireConnection;412;0;416;0
WireConnection;479;0;514;0
WireConnection;479;1;544;0
WireConnection;625;0;636;0
WireConnection;625;1;624;0
WireConnection;506;0;509;0
WireConnection;489;0;495;0
WireConnection;596;0;586;0
WireConnection;485;0;479;0
WireConnection;485;1;412;0
WireConnection;626;0;625;0
WireConnection;439;0;440;0
WireConnection;507;0;489;0
WireConnection;507;1;506;0
WireConnection;615;0;596;0
WireConnection;629;0;626;0
WireConnection;486;0;485;0
WireConnection;486;1;439;0
WireConnection;634;1;629;0
WireConnection;491;0;507;0
WireConnection;637;0;486;0
WireConnection;637;1;638;0
WireConnection;637;2;615;0
WireConnection;188;0;238;76
WireConnection;188;1;237;76
WireConnection;510;0;491;0
WireConnection;639;0;637;0
WireConnection;639;1;640;0
WireConnection;639;2;634;0
WireConnection;189;0;188;0
WireConnection;641;0;639;0
WireConnection;641;1;642;0
WireConnection;641;2;510;0
WireConnection;247;2;641;0
WireConnection;247;11;191;0
WireConnection;247;12;189;0
ASEEND*/
//CHKSM=235A82DC2B42A12EDBB01BCCA40274CA69E24A7D