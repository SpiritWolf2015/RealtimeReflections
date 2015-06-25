using UnityEngine;
using System;
using System.Collections;

//[ExecuteInEditMode()]
public class RealtimeReflections : MonoBehaviour
{
	public int cubemapSize = 128;
	public float nearClip = 0.01f;
	public float farClip = 500;
	public bool oneFacePerFrame = false;
	public Material[] materials;
	public LayerMask layerMask = -1;
	private Camera cam;
	private RenderTexture renderTexture;

	void OnEnable(){
		layerMask.value = -1;
	}

	void Start()
	{
		UpdateCubemap(63);
	}

	void LateUpdate()
	{
		if (oneFacePerFrame)
		{
			int faceToRender = Time.frameCount % 6;
			int faceMask = 1 << faceToRender;
			UpdateCubemap(faceMask);
		}
		else
		{
			UpdateCubemap(63); // all six faces
		}
	}

	void UpdateCubemap(int faceMask)
	{
		if (!cam)
		{
			GameObject go = new GameObject("CubemapCamera", typeof(Camera));
			go.hideFlags = HideFlags.HideAndDontSave;
			go.transform.position = transform.position;
			go.transform.rotation = Quaternion.identity;
			cam = go.camera;
			cam.cullingMask = layerMask;
			cam.nearClipPlane = nearClip;
			cam.farClipPlane = farClip;
			cam.enabled = false;
		}

		if (!renderTexture)
		{
			renderTexture = new RenderTexture(cubemapSize, cubemapSize, 16);
			renderTexture.isPowerOfTwo = true;
			renderTexture.isCubemap = true;
			renderTexture.hideFlags = HideFlags.HideAndDontSave;
			foreach (Renderer r in GetComponentsInChildren<Renderer>())
			{
				foreach (Material m in r.sharedMaterials)
				{
					if (m.HasProperty("_Cube"))
						m.SetTexture("_Cube", renderTexture);
				}
			}
		}

		cam.transform.position = transform.position;
		cam.RenderToCubemap(renderTexture, faceMask);
	}

	void OnDisable()
	{
		DestroyImmediate(cam);
		DestroyImmediate(renderTexture);
	}
}
