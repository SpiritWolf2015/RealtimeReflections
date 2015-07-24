/*
2015年6月25日 15:15:49 郭志程
镜子效果，使用的是Fixed function shader

用的是Asset store上的一个免费Shader
Realtime Reflections
https://www.assetstore.unity3d.com/cn/#!/content/21730
这个是1.1版，2015-6-23
要求U3D4.3.2以上，U3D4.X要求是PRO版的U3D，U3D5不能用。

风宇冲】Unity3D教程宝典之Shader篇：第二讲Fixed Function Shader 
http://blog.sina.com.cn/s/blog_471132920101d5of.html


与MirrorReflection等价的用顶点片断Shader来写。
*/

Shader "RealtimeReflections/MirrorReflection2" { 
	Properties {
		_MainTex ("Base", 2D) = "white" 
		 _ReflectionTex ("反射纹理", 2D) = "white"{ TexGen ObjectLinear }
		//_TintColor ("着色 (RGB)", Color) = (1, 1, 1)
	}
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _ReflectionTex;
            
            float4 _MainTex_ST;
            float4x4 _ProjMatrix;

			struct appdata{
				 float4 vertex : POSITION;
				 float2 texcoord : TEXCOORD0;
			};
            struct v2f {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
            } ;
            
            v2f vert (appdata v) {
                v2f o = (v2f)0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX( v.texcoord, _MainTex );
                return o;
            }
            half4 frag (v2f i) : COLOR {
            	float2 newUV = mul(_ProjMatrix, half4(i.uv, 0, 0)).xy;
            	half4 c = tex2D(_ReflectionTex, newUV);
                return c;
            }
            ENDCG
        }
    }
	
	// 备胎
	FallBack "Diffuse"
}