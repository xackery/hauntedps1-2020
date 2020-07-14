using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class PSXEffects : MonoBehaviour {

	public enum DitherType {
		x2,
		x3,
		x4,
		x8
	};

	public int resolutionFactor = 2;
	public RawImage imgTarget;
	public int limitFramerate = 30;
	public bool affineMapping = true;
	public float polygonalDrawDistance = 0f;
	public int vertexInaccuracy = 30;
	public int polygonInaccuracy = 10;
	public int colorDepth = 32;
	public bool scanlines = false;
	public int scanlineIntensity = 5;
	public Texture2D ditherTexture;
	public bool dithering = true;
	public float ditherThreshold = 1;
	public int ditherIntensity = 5;
	public int maxDarkness = 20;
	public int subtractFade = 0;
	public bool skyboxLighting = false;
	public float favorRed = 1.0f;
	public bool worldSpaceSnapping = false;
	public bool postProcessing = true;
	public bool verticalScanlines = true;
	public float shadowIntensity = 0.5f;

	private Camera cam;
	private Material colorDepthMat;
	private int prevResFactor;
	private Vector2 screenRes;

	void Awake() {
		if (Application.isPlaying) {
			QualitySettings.vSyncCount = 0;
		}

		if (imgTarget != null && postProcessing) {
			CreateNewRendTexture();
		}

		prevResFactor = resolutionFactor;
		screenRes = new Vector2(Screen.width, Screen.height);
	}

	void Update() {
		Shader.SetGlobalFloat("_AffineMapping", affineMapping ? 1.0f : 0.0f);
		Shader.SetGlobalFloat("_DrawDistance", polygonalDrawDistance);
		Shader.SetGlobalInt("_VertexSnappingDetail", vertexInaccuracy / resolutionFactor);
		Shader.SetGlobalInt("_Offset", polygonInaccuracy);
		Shader.SetGlobalFloat("_DarkMax", (float)maxDarkness / 100);
		Shader.SetGlobalFloat("_SubtractFade", (float)subtractFade / 100);
		Shader.SetGlobalFloat("_SkyboxLighting", skyboxLighting ? 1.0f : 0.0f);
		Shader.SetGlobalFloat("_WorldSpace", worldSpaceSnapping ? 1.0f : 0.0f);

		if (postProcessing) {
			imgTarget.gameObject.SetActive(true);
			if (colorDepthMat == null) {
				colorDepthMat = new Material(Shader.Find("Hidden/PS1ColorDepth"));
			} else {
				colorDepthMat.SetFloat("_ColorDepth", colorDepth);
				colorDepthMat.SetFloat("_Scanlines", scanlines ? 1 : 0);
				colorDepthMat.SetFloat("_ScanlineIntensity", (float)scanlineIntensity / 100);
				colorDepthMat.SetTexture("_DitherTex", ditherTexture);
				colorDepthMat.SetFloat("_Dithering", dithering ? 1 : 0);
				colorDepthMat.SetFloat("_DitherThreshold", ditherThreshold);
				colorDepthMat.SetFloat("_DitherIntensity", (float)ditherIntensity / 100);
				colorDepthMat.SetFloat("_FavorRed", favorRed);
				colorDepthMat.SetFloat("_SLDirection", verticalScanlines ? 1 : 0);
			}

			if (prevResFactor != resolutionFactor) {
				prevResFactor = resolutionFactor;
				CreateNewRendTexture();
			}

			if (screenRes.x != Screen.width || screenRes.y != Screen.height) {
				screenRes = new Vector2(Screen.width, Screen.height);
				CreateNewRendTexture();
			}
		} else {
			imgTarget.gameObject.SetActive(false);
		}

		Application.targetFrameRate = limitFramerate;
	}

	void OnRenderImage(RenderTexture source, RenderTexture destination) {
		if (postProcessing) {
			Graphics.Blit(source, destination, colorDepthMat);
		}
	}

	void CreateNewRendTexture() {
		int resolution = Screen.width / resolutionFactor;

		cam = GetComponent<Camera>();
		if (resolution > 0) {
			cam.targetTexture = new RenderTexture(resolution, (int)(resolution * ((float)Screen.height / (float)Screen.width)), 32, RenderTextureFormat.RGB111110Float);
			cam.targetTexture.filterMode = FilterMode.Point;

			imgTarget.texture = cam.targetTexture;
		}
	}
}
