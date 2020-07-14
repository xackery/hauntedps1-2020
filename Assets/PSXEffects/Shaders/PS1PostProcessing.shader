Shader "Hidden/PS1ColorDepth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DitherTex("", 2D) = "black" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _DitherTex;
			float _ColorDepth;
			float _Scanlines;
			float _ScanlineIntensity;
			float _Dithering;
			float _DitherThreshold;
			float _DitherIntensity;
			float _SubtractFade;
			float _FavorRed;
			float _SLDirection;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb = floor(col.rgb * _ColorDepth) / _ColorDepth;
				//Scanlines
				float sl = floor(i.uv.x*_ScreenParams.x % 2) * _SLDirection + floor(i.uv.y*_ScreenParams.y % 2) * (1 - _SLDirection);
				col.rgb += _Scanlines * sl * _ScanlineIntensity;
				
				#ifdef UNITY_COLORSPACE_GAMMA
					half luma = LinearRgbToLuminance(GammaToLinearSpace(saturate(col.rgb)));
				#else
					half luma = LinearRgbToLuminance(col.rgb);
				#endif
				half dither = tex2D(_DitherTex, i.uv*(_ScreenParams.x/6)).a;

				col.rgb += (luma < dither / _DitherThreshold ? _DitherIntensity : 0) * _Dithering;
				col.rgb -= (3 - col.rgb) * _SubtractFade;
				col.rgb -= _FavorRed * ((1 - col.rgb) * 0.25);
				col.r += _FavorRed * ((0.5 - col.rgb) * 0.1);

				return col;
			}
			ENDCG
		}
	}
}
