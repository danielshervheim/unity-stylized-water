// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Stylized/Water Underside"
{
	Properties
	{
		_RefractionContribution("Refraction Contribution", Range( 0 , 1)) = 1
		_Color("Color", Color) = (0,0,0,0)
		[NoScaleOffset][Normal]_WaveNormal("Wave Normal", 2D) = "bump" {}
		_WaveNormalScale("Wave Normal  Scale", Float) = 50
		_WaveNormalSpeed("Wave Normal Speed", Float) = 0.25
		_WaterplaneOffset("Waterplane Offset", Float) = 0
		_RefractionGradient("Refraction Gradient", Float) = 1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha addshadow fullforwardshadows nodynlightmap nodirlightmap 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform sampler2D _GrabTexture;
		uniform sampler2D _WaveNormal;
		uniform half _WaveNormalSpeed;
		uniform half _WaveNormalScale;
		uniform half _RefractionContribution;
		uniform half _WaterplaneOffset;
		uniform half _RefractionGradient;
		uniform half4 _Color;


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


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime6_g48 = _Time.y * _WaveNormalSpeed;
			float Time23_g48 = mulTime6_g48;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult3_g47 = (half2(ase_worldPos.x , ase_worldPos.z));
			float2 Coordinates22_g48 = ( appendResult3_g47 / _WaveNormalScale );
			float2 panner14_g48 = ( Time23_g48 * half2( 0.1,0.1 ) + Coordinates22_g48);
			float2 panner15_g48 = ( Time23_g48 * half2( -0.1,-0.1 ) + ( Coordinates22_g48 + half2( 0.418,0.355 ) ));
			float2 panner16_g48 = ( Time23_g48 * half2( -0.1,0.1 ) + ( Coordinates22_g48 + half2( 0.865,0.148 ) ));
			float2 panner17_g48 = ( Time23_g48 * half2( 0.1,-0.1 ) + ( Coordinates22_g48 + half2( 0.651,0.752 ) ));
			float3 normalizeResult7 = normalize( ( ( UnpackNormal( tex2D( _WaveNormal, panner14_g48 ) ) + UnpackNormal( tex2D( _WaveNormal, panner15_g48 ) ) + UnpackNormal( tex2D( _WaveNormal, panner16_g48 ) ) + UnpackNormal( tex2D( _WaveNormal, panner17_g48 ) ) ) / 4.0 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor14 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( ( (normalizeResult7).x * _RefractionContribution * saturate( abs( ( saturate( -( _WorldSpaceCameraPos.y + _WaterplaneOffset ) ) / _RefractionGradient ) ) ) ) + ase_grabScreenPosNorm ) ) );
			o.Emission = ( screenColor14 * _Color ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
7;176;1906;835;1708.867;205.4145;1.3;True;False
Node;AmplifyShaderEditor.RangedFloatNode;22;-1598.657,403.8951;Float;False;Property;_WaterplaneOffset;Waterplane Offset;7;0;Create;True;0;0;False;0;0;2.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;17;-1645.542,252.3156;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1363.658,351.895;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;18;-1241.251,350.7398;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1616.995,-24.66778;Float;False;Property;_WaveNormalScale;Wave Normal  Scale;3;0;Create;True;0;0;False;0;50;75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;3;-1394.102,-20.47931;Float;False;WorldPositionXZ;-1;;47;409d61e1d315a484388d8ae966642b06;0;1;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1362.966,55.57265;Float;False;Property;_WaveNormalSpeed;Wave Normal Speed;4;0;Create;True;0;0;False;0;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1364.459,138.2988;Float;True;Property;_WaveNormal;Wave Normal;2;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;fab6b5b579fb24c1aa6ddc2fa68e4333;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1177.757,438.2957;Float;False;Property;_RefractionGradient;Refraction Gradient;8;0;Create;True;0;0;False;0;1;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;26;-1099.302,349.8381;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;25;-938.7582,380.2954;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;5;-1115.408,37.66835;Float;False;MotionFourWayChaosNormal;5;;48;ac538d4bcae1f4cdfb4426dbd82dd2d1;0;3;11;FLOAT2;0,0;False;10;FLOAT;1;False;7;SAMPLER2D;;False;1;FLOAT3;21
Node;AmplifyShaderEditor.NormalizeNode;7;-796.1664,36.47424;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;19;-812.5505,379.3833;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;20;-670.177,378.04;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-747.8284,117.4899;Float;False;Property;_RefractionContribution;Refraction Contribution;0;0;Create;True;0;0;False;0;1;0.77;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;9;-623.8284,31.48987;Float;False;FLOAT;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-437.2675,99.43153;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;13;-521.7395,232.5392;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-261.4459,152.6712;Float;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;16;-164.5021,331.463;Float;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;0,0,0,0;0.6462264,1,0.859405,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;14;-133.4958,148.1968;Float;False;Global;_GrabScreen0;Grab Screen 0;35;0;Create;True;0;0;False;0;Object;-1;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;69.01122,240.9438;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;239.0926,193.5139;Half;False;True;2;Half;ASEMaterialInspector;0;0;Unlit;Stylized/Water Underside;False;False;False;False;False;False;False;True;True;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;1;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;17;2
WireConnection;21;1;22;0
WireConnection;18;0;21;0
WireConnection;3;1;1;0
WireConnection;26;0;18;0
WireConnection;25;0;26;0
WireConnection;25;1;24;0
WireConnection;5;11;3;0
WireConnection;5;10;4;0
WireConnection;5;7;2;0
WireConnection;7;0;5;21
WireConnection;19;0;25;0
WireConnection;20;0;19;0
WireConnection;9;0;7;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;11;2;20;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;14;0;12;0
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;0;2;15;0
ASEEND*/
//CHKSM=62C31BCC2FBA215F3C09E4C436A70E4BC9AE7D6B