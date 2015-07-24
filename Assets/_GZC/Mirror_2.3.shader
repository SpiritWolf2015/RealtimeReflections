/*
	2015年6月23日 16:52:38 郭志程
	顶点片断Shader
	平面镜反射效果
*/

Shader "Tut/Rays/Mirror_2.3" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_RefTex ("反射贴图（Render Texture）", 2D) = "white" {}	// 镜像相机的渲染结果
	}
	SubShader {
		pass{
			Tags {"LightMode"="Always"}
			Cull Back

			CGPROGRAM

			// 声明顶点函数
			#pragma vertex vert
			// 声明片断函数
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"			

			// 声明变量，结构体
			sampler2D _RefTex;
			half4 _Color;
			half4x4 _ProjMat;		//float4x4 _ProjMat;	// 在镜像相机空间内的投影矩阵

			struct v2f {
// http://forum.unity3d.com/threads/what-is-the-difference-between-float4-pos-sv_position-and-float4-pos.165351/
			// 在DX11里，SV_开头的是系统提前定义的变量，
			// 如果使用SV_POSITION就相当于告诉系统这个是用于存储顶点位置。
			// 在DX11之前，SV_POSITION相当于就是POSITION。
			// 以后最好用SV_POSITION吧。
				fixed4  pos:SV_POSITION;	//float4
				half4  texc:TEXCOORD0;			
			};

			// 顶点函数
			v2f vert(appdata_base v) {
				//float4x4 proj;
				half4x4 proj;
				proj = mul(_ProjMat, _Object2World);		// 把镜子物体的顶点先转到世界坐标
				v2f o = (v2f)0;
				// 把顶点的位置和Unity提前定义的一
				// 个矩阵UNITY_MATRIX_MVP（在UnityShaderVariables.cginc里定义）相乘，
				// 从而把顶点位置从model space转换到projection space。
				// 我们使用了矩阵乘法操作mul来执行这个步骤。
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texc = mul(proj, v.vertex);		
				
				return o;
			}
			// 片断函数
			half4 frag(v2f i):COLOR {
				half4 c = tex2Dproj(_RefTex, i.texc) * _Color;	// 投射到镜子物体上							
				return c;
			}			
			ENDCG
		}//endpass		
	} 
	// 备胎
	Fallback "Diffuse"
}
