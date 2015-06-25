/*
2015年6月25日 15:15:49 郭志程
镜子效果，使用的是Fixed function shader

用的是Asset store上的一个免费Shader
Realtime Reflections
https://www.assetstore.unity3d.com/cn/#!/content/21730
这个是1.1版，2015-6-23
要求U3D4.3.2以上，U3D4.X要求是PRO版的U3D，U3D5能用。

风宇冲】Unity3D教程宝典之Shader篇：第二讲Fixed Function Shader 
http://blog.sina.com.cn/s/blog_471132920101d5of.html
*/

Shader "Realtime Reflections/Planar Reflection" { 
    Properties {
//        _MainAlpha("主纹理Alpha（0到1）", Range(0, 1)) = 0
//        _ReflectionAlpha("反射纹理Alpha（0到1）", Range(0, 1)) = 1
        _TintColor ("着色 (RGB)", Color) = (1, 1, 1)
//        _MainTex ("主纹理(RGBA)", 2D) = ""

		//TexGen全称是Texture coordinate generation，即纹理坐标生成
        _ReflectionTex ("反射纹理", 2D) = "white" { TexGen ObjectLinear }	
		//【风宇冲】Unity3D教程宝典之Shader篇：第六讲TexGen
		//http://blog.sina.com.cn/s/blog_471132920101d9mt.html
    }
 
    //Two texture cards: full thing
    Subshader { 
        Tags {Queue = Transparent}
//        Tags {Queue = Opaque}
        // ZWrite可以取的值为：On/Off，默认值为On，代表是否要将像素的深度写入深度缓存中
//        ZWrite Off
//        Colormask RGBA
        Color [_TintColor]
//        Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            SetTexture[_ReflectionTex] {
//				constantColor(0, 0, 0, [_ReflectionAlpha])
				matrix [_ProjMatrix] 
//				combine texture * previous, constant
				combine texture * previous
			} 
        }
//        Pass {
//            SetTexture[_MainTex] {
//				constantColor(0,0,0, [_MainAlpha]) 
//				//combine color部分，alpha部分
//                //      材质 * 顶点颜色			
//				combine texture * primary, texture * constant
//			}
//        }
    }
 
    //Fallback: just main texture	
    //Subshader {
    //    Pass {
    //        SetTexture [_MainTex] { combine texture }
    //    }		
    //}
	
	// 备胎
	FallBack "Diffuse"
}