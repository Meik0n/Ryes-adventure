// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CameraFilter"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_Color0("Color 0", Color) = (1,1,1,0)
		_MinimumMaximum("MinimumMaximum", Vector) = (1.48,0.44,0,0)
		_Intensity("Intensity", Float) = 1
		_TimeScale("TimeScale", Float) = 3.73
		_Sin("Sin", Float) = 2.87
		_Tiled("Tiled", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend One One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _TimeScale;
		uniform float _Sin;
		uniform float2 _MinimumMaximum;
		uniform sampler2D _TextureSample1;
		uniform float4 _TextureSample1_ST;
		uniform float _Intensity;
		uniform float4 _Color0;
		uniform sampler2D _TextureSample0;
		uniform float _Tiled;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime21 = _Time.y * _TimeScale;
			float temp_output_24_0 = sin( _Sin );
			float lerpResult23 = lerp( _MinimumMaximum.x , _MinimumMaximum.y , temp_output_24_0);
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			float2 temp_cast_0 = (_Tiled).xx;
			float2 uv_TexCoord33 = i.uv_texcoord * temp_cast_0;
			float4 tex2DNode4 = tex2D( _TextureSample0, uv_TexCoord33 );
			o.Emission = ( ( (0.8 + (sin( ( mulTime21 * temp_output_24_0 * lerpResult23 ) ) - -1.0) * (1.1 - 0.8) / (1.0 - -1.0)) * tex2D( _TextureSample1, uv_TextureSample1 ) ) * ( _Intensity * ( _Color0 * tex2DNode4 ) ) ).rgb;
			float3 desaturateInitialColor6 = tex2DNode4.rgb;
			float desaturateDot6 = dot( desaturateInitialColor6, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar6 = lerp( desaturateInitialColor6, desaturateDot6.xxx, 1.0 );
			o.Alpha = desaturateVar6.x;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
0;20;1906;1009;2002.398;986.8455;1.133466;True;True
Node;AmplifyShaderEditor.RangedFloatNode;28;-1494.033,-264.3766;Float;False;Property;_Sin;Sin;7;0;Create;True;0;0;False;0;2.87;2.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;24;-1300.868,-258.5894;Float;False;1;0;FLOAT;2.44;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;26;-1321.01,-381.6802;Float;False;Property;_MinimumMaximum;MinimumMaximum;4;0;Create;True;0;0;False;0;1.48,0.44;1.48,0.44;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;29;-1491.033,-683.3766;Float;False;Property;_TimeScale;TimeScale;6;0;Create;True;0;0;False;0;3.73;3.73;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-1253.73,-680.3268;Float;True;1;0;FLOAT;2.09;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1484.776,-33.23501;Float;False;Property;_Tiled;Tiled;8;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;23;-1052.144,-307.8861;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1014.402,-621.1481;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-1267.608,-50.51006;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-1014.392,-79.67706;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;a3b5a3279938ec14c86630ace65f7211;a3b5a3279938ec14c86630ace65f7211;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-652.9539,-266.9142;Float;False;Property;_Color0;Color 0;2;0;Create;True;0;0;False;0;1,1,1,0;0.8679245,0.642905,0.4216803,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;20;-880.3513,-621.9615;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-668.4514,-603.5271;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;8c4a7fca2884fab419769ccc0355c0c1;8c4a7fca2884fab419769ccc0355c0c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-424.9539,-135.9142;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-597.7145,-352.46;Float;False;Property;_Intensity;Intensity;5;0;Create;True;0;0;False;0;1;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;16;-680.5697,-850.4855;Float;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.8;False;4;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-345.4514,-621.5271;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-285,-213;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DesaturateOpNode;6;-96.00957,-73.61906;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;34;-1250.678,125.3704;Float;False;True;True;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;36;-1518.012,131.0889;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;32;-1870.769,132.4947;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-95.76971,-286.5855;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;245,-258;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;CameraFilter;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;3;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;24;0;28;0
WireConnection;21;0;29;0
WireConnection;23;0;26;1
WireConnection;23;1;26;2
WireConnection;23;2;24;0
WireConnection;27;0;21;0
WireConnection;27;1;24;0
WireConnection;27;2;23;0
WireConnection;33;0;37;0
WireConnection;4;1;33;0
WireConnection;20;0;27;0
WireConnection;8;0;7;0
WireConnection;8;1;4;0
WireConnection;16;0;20;0
WireConnection;31;0;16;0
WireConnection;31;1;30;0
WireConnection;10;0;9;0
WireConnection;10;1;8;0
WireConnection;6;0;4;0
WireConnection;34;0;36;0
WireConnection;36;0;32;0
WireConnection;13;0;31;0
WireConnection;13;1;10;0
WireConnection;0;2;13;0
WireConnection;0;9;6;0
ASEEND*/
//CHKSM=5F0C4A85DE3D2539BB64ADBD7C6960BC1BA17A6E