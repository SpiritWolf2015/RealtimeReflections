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
*/

Shader "RealtimeReflections/MirrorReflection" { 
    Properties {
        _TintColor ("着色 (RGB)", Color) = (1, 1, 1)

		//TexGen全称是Texture coordinate generation，即纹理坐标生成
        _ReflectionTex ("反射纹理", 2D) = "white" { TexGen ObjectLinear }	
		//【风宇冲】Unity3D教程宝典之Shader篇：第六讲TexGen
		//http://blog.sina.com.cn/s/blog_471132920101d9mt.html
		// TexGen只能在U3D4.X使用，在U3D5.X已经废弃。
    } 
    
    Subshader { 
    	// 在所有不透明几何结构之后进行自我绘制
        Tags { Queue = Transparent }
//        Tags {Queue = Opaque}
        // ZWrite可以取的值为：On/Off，默认值为On，代表是否要将像素的深度写入深度缓存中
        ZWrite On
//        Colormask RGBA

		// 如果顶点光照是关闭的，则设置使用的颜色。
        Color [_TintColor]		
        //ShaderLab 语法：Pass
        //http://uec.unity3d.com/learning/document?file=/Components/SL-Pass.html        
        
//        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
        //SetTexture texture property { [Combine options] }
//纹理设置可配置固定功能多层材质管线，并且如果使用自定义片段着色器，则纹理设置将被忽视。 
            SetTexture[_ReflectionTex] {
//				constantColor(0, 0, 0, [_ReflectionAlpha])
				matrix [_ProjMatrix] 
				
//				combine texture * previous, constant
//combine src1 * src2 将 src1 和 src2 相乘。结果比会比单独输入任何一个都要暗
				combine texture * previous
				//ShaderLab 语法：纹理组合器 (Texture Combiners)
				//http://uec.unity3d.com/learning/document?file=/Components/SL-SetTexture.html
			} 
        }

    }
	
	// 备胎
	FallBack "Diffuse"
}