// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/PS1Shader"
{
	Properties
	{
		[Toggle] _Unlit("Unlit", Float) = 0.0
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_SpecularMap("Specular Map", 2D) = "white" {}
		_Specular("Specular Amount", Float) = 0.0
		_MetalMap("Metal Map", 2D) = "white" {}
		_Metallic("Metallic Amount", Range(0.0,1.0)) = 0.0
		_Smoothness("Smoothness Amount", Range(0.0,1.0)) = 0.5
		_Emission("Emission Map", 2D) = "white" {}
		_EmissionAmt("Emission Amount", Float) = 0.0
		_Cube("Cubemap", Cube) = "" {}

		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
		[HideInInspector] _Cul("__cul", Float) = 0.0
	}
		SubShader
	{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		LOD 100
		Lighting On
		Offset[_Offset], 1
		Cull [_Cul]
		Blend[_SrcBlend][_DstBlend]

		Pass
	{
		CGPROGRAM

		sampler2D _MainTex;
		sampler2D _Emission;
		sampler2D _NormalMap;
		sampler2D _SpecularMap;
		sampler2D _MetalMap;
	float4 _MainTex_ST;
	float _VertexSnappingDetail;
	float _AffineMapping;
	float _DrawDistance;
	float _Specular;
	float4 _Color;
	float _DarkMax;
	float _Unlit;
	float _SkyboxLighting;
	float _WorldSpace;
	float _EmissionAmt;
	float _Metallic;
	float _Smoothness;
	uniform samplerCUBE _Cube;

	float _Transparent;

#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "AutoLight.cginc"

#pragma vertex vert
#pragma fragment frag
	//#pragma geometry geom
#pragma multi_compile_fwdbase
#pragma multi_compile_fog
#pragma multi_compile _ LIGHTMAP_ON
#pragma shader_feature TRANSPARENT
#pragma shader_feature BFC

	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
		float4 color : COLOR;
		float3 tangent: TANGENT;
#ifdef LIGHTMAP_ON
		float2 uv_lightmap : TEXCOORD1;
#endif
	};

	struct v2f
	{
		float3 uv : TEXCOORD0;
		float4 color : COLOR;
		fixed4 diff : COLOR1;
		float4 pos : SV_POSITION;
		float3 uv_lightmap : TEXCOORD1;
		float3 uv_affine : TEXCOORD2;
		float4 vertPos : COORDINATE0;
		float3 normal : NORMAL;
		float3 normalDir : TEXCOORD3;
		float3 viewDir : TEXCOORD4;
		float3 lightDir : TEXCOORD5;

		float3 T : TEXCOORD6;
		float3 B : TEXCOORD7;
		float3 N : TEXCOORD8;
		LIGHTING_COORDS(9, 10)
		UNITY_FOG_COORDS(11)
	};

	float4 PixelSnap(float4 pos)
	{
		float2 hpc = _ScreenParams.xy * 0.75f;
		_VertexSnappingDetail /= 8;
		float2 pixelPos = round((pos.xy / pos.w) * hpc / _VertexSnappingDetail)*_VertexSnappingDetail;
		pos.xy = pixelPos / hpc * pos.w;
		return pos;
	}

	v2f vert(appdata v)
	{
		v2f o;

		float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
		o.pos = UnityObjectToClipPos(v.vertex);
		o.pos = PixelSnap(o.pos);

		float wVal = mul(UNITY_MATRIX_P, o.pos).z;
		o.uv = v.texcoord;
		o.uv_affine = float3(v.texcoord.xy * wVal, wVal);

		float3 worldNormal = UnityObjectToWorldNormal(v.normal);
		half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
		o.diff = nl * _LightColor0;
		if (_SkyboxLighting == 1) {
			o.diff.rgb += ShadeSH9(half4(worldNormal, 1));
		} else {
			o.diff.rgb += 0.5;
		}
		o.diff.a = 1;

		if (distance(worldPos, _WorldSpaceCameraPos) > _DrawDistance && _DrawDistance > 0) {
			o.diff.a = 0;
		}

		o.color = v.color;
		o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
		o.vertPos = v.vertex;

		for (int j = 0; j < 4; j++) {
			float4 lightPos = float4(unity_4LightPosX0[j], unity_4LightPosY0[j], unity_4LightPosZ0[j], 1.0);

			float3 vertexToLightSource = lightPos.xyz - worldPos.xyz;
			float3 lightDir = normalize(vertexToLightSource);
			float squaredDist = dot(vertexToLightSource, vertexToLightSource);
			float atten = 1.0 / (1.0 + unity_4LightAtten0[j] * squaredDist);
			o.color.rgb += atten * unity_LightColor[j].rgb * _Color.rgb * max(0.0, dot(o.normal, lightDir));
		}

		o.viewDir = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;
		o.normalDir = normalize(mul(float4(v.normal, 0), unity_WorldToObject).xyz);

		o.diff.rgb += UNITY_LIGHTMODEL_AMBIENT;

		o.uv_lightmap = float3(1, 1, 1);
		#ifdef LIGHTMAP_ON
			o.uv_lightmap = float3(v.uv_lightmap.xy * unity_LightmapST.xy + unity_LightmapST.zw, 1.0);
		#endif

		float3 lightDir = worldPos.xyz - _WorldSpaceLightPos0.xyz;
		o.lightDir = normalize(lightDir);


		worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
		float3 worldTangent = mul((float3x3)unity_ObjectToWorld, v.normal);
		float3 binormal = cross(v.normal, v.tangent.xyz);
		float3 worldBinormal = mul((float3x3)unity_ObjectToWorld, -binormal);

		o.N = normalize(worldNormal);
		o.T = normalize(worldTangent);
		o.B = normalize(worldBinormal);

		UNITY_TRANSFER_FOG(o, o.pos);
		TRANSFER_VERTEX_TO_FRAGMENT(o);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{

		float2 adjUv = lerp((i.uv + _MainTex_ST.zw) * _MainTex_ST.xy, (i.uv_affine / i.uv_affine.z + _MainTex_ST.zw) * _MainTex_ST.xy, _AffineMapping);

		float3 tangentNormal = tex2D(_NormalMap, adjUv).xyz;
		tangentNormal = normalize(tangentNormal * 2 - 1);
		float3x3 TBN = float3x3(normalize(i.T), normalize(i.B), normalize(i.N));
		TBN = transpose(TBN);
		float3 worldNormal = mul(TBN, tangentNormal);

		
		float3 reflectedDir = reflect(i.viewDir, normalize(i.normalDir));
		float3 lightDir = normalize(i.lightDir);
		float4 albedo = tex2D(_MainTex, adjUv);
		float nl = (max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz)) * (1 - _Unlit));
		if (_SkyboxLighting == 1) {
			nl += ShadeSH9(half4(worldNormal, 1));
		} else {
			nl += 0.5;
		}
		float4 diffuse = float4((albedo * nl).rgb, albedo.a);

		float3 specular = 0;
		if (diffuse.x > 0) {
			float3 reflection = reflect(lightDir, worldNormal);
			float3 viewDir = normalize(i.viewDir);
			specular = saturate(dot(reflection, -viewDir));
			specular = pow(specular, 20.0f);

			float4 specularIntensity = tex2D(_SpecularMap, adjUv) * _Specular;
			specular *= specularIntensity;
		}

		float4 col = diffuse;

		float4 metalMap = tex2D(_MetalMap, adjUv);
		UnityIndirect indirectLight;
		indirectLight.diffuse = 0;
		indirectLight.specular = 0;
		indirectLight.diffuse += max(0, ShadeSH9(half4(i.normal, 1)));
		_Smoothness = metalMap.a;
		float roughness = 1 - _Smoothness;
		float3 reflectionDir = reflect(i.viewDir, i.normal);
		float4 envRefl = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDir, roughness * 6);
		indirectLight.specular = DecodeHDR(envRefl, unity_SpecCube0_HDR);

		col.rgb *= (indirectLight.specular + indirectLight.diffuse) * _Metallic * metalMap.r;
		col += diffuse * (1-_Metallic);
		col.rgb += specular;
		col.rgb += texCUBE(_Cube, reflectedDir) / 2 - 0.25;
		#ifdef LIGHTMAP_ON
			col.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv_lightmap)).rgb * 2;
		#endif

		col *= i.color;
		col *= _Color;
		col *= LIGHT_ATTENUATION(i);
		col.rgb -= max(0, (1 - i.diff.rgb)*i.color)*_DarkMax;
		col.rgb += tex2D(_Emission, adjUv) * _EmissionAmt;

		if (i.diff.a == 0) {
			clip(-1);
		}

		UNITY_APPLY_FOG(i.fogCoord, col);

		return col;
	}
		ENDCG
	}
	}
	CustomEditor "PS1ShaderEditor"
		Fallback "VertexLit"
}
