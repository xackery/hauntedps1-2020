using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;

[CustomEditor(typeof(PSXEffects))]
public class PSXEffectsEditor : Editor {

	SerializedProperty resolutionFactor;
	SerializedProperty screenCanvas;
	SerializedProperty limitFramerate;
	SerializedProperty affineMapping;
	SerializedProperty polygonalDrawDistance;
	SerializedProperty vertexInaccuracy;
	SerializedProperty polygonInaccuracy;
	SerializedProperty colorDepth;
	SerializedProperty scanlines;
	SerializedProperty scanlineIntensity;
	SerializedProperty dithering;
	SerializedProperty ditherType;
	SerializedProperty ditherThreshold;
	SerializedProperty ditherIntensity;
	SerializedProperty maxDarkness;
	SerializedProperty subtractFade;
	SerializedProperty skyboxLighting;
	SerializedProperty favorRed;
	SerializedProperty postProcessing;
	SerializedProperty verticalScanlines;

	void OnEnable() {
		resolutionFactor = serializedObject.FindProperty("resolutionFactor");
		screenCanvas = serializedObject.FindProperty("imgTarget");
		limitFramerate = serializedObject.FindProperty("limitFramerate");
		affineMapping = serializedObject.FindProperty("affineMapping");
		polygonalDrawDistance = serializedObject.FindProperty("polygonalDrawDistance");
		vertexInaccuracy = serializedObject.FindProperty("vertexInaccuracy");
		polygonInaccuracy = serializedObject.FindProperty("polygonInaccuracy");
		colorDepth = serializedObject.FindProperty("colorDepth");
		scanlines = serializedObject.FindProperty("scanlines");
		scanlineIntensity = serializedObject.FindProperty("scanlineIntensity");
		dithering = serializedObject.FindProperty("dithering");
		ditherType = serializedObject.FindProperty("ditherTexture");
		ditherThreshold = serializedObject.FindProperty("ditherThreshold");
		ditherIntensity = serializedObject.FindProperty("ditherIntensity");
		maxDarkness = serializedObject.FindProperty("maxDarkness");
		subtractFade = serializedObject.FindProperty("subtractFade");
		skyboxLighting = serializedObject.FindProperty("skyboxLighting");
		favorRed = serializedObject.FindProperty("favorRed");
		postProcessing = serializedObject.FindProperty("postProcessing");
		verticalScanlines = serializedObject.FindProperty("verticalScanlines");
	}

	public override void OnInspectorGUI() {
		serializedObject.Update();

		EditorGUILayout.LabelField("Video Output", EditorStyles.boldLabel);
		screenCanvas.objectReferenceValue = EditorGUILayout.ObjectField("Screen Canvas", screenCanvas.objectReferenceValue, typeof(RawImage), true);
		resolutionFactor.intValue = EditorGUILayout.IntSlider("Resolution Factor", resolutionFactor.intValue, 1, 40);
		limitFramerate.intValue = EditorGUILayout.IntField("Limit Framerate", limitFramerate.intValue);
		EditorGUILayout.Separator();

		EditorGUILayout.LabelField("Mesh Settings", EditorStyles.boldLabel);
		affineMapping.boolValue = EditorGUILayout.Toggle("Affine Texture Mapping", affineMapping.boolValue);
		polygonalDrawDistance.floatValue = EditorGUILayout.FloatField("Polygonal Draw Distance", polygonalDrawDistance.floatValue);
		polygonInaccuracy.intValue = EditorGUILayout.IntField("Polygon Inaccuracy", polygonInaccuracy.intValue);
		vertexInaccuracy.intValue = EditorGUILayout.IntField("Vertex Inaccuracy", vertexInaccuracy.intValue);
		maxDarkness.intValue = EditorGUILayout.IntSlider("Saturated Diffuse", maxDarkness.intValue, 0, 100);
		skyboxLighting.boolValue = EditorGUILayout.Toggle("Use Skybox Lighting", skyboxLighting.boolValue);
		EditorGUILayout.Separator();

		EditorGUILayout.LabelField("Post Processing", EditorStyles.boldLabel);
		postProcessing.boolValue = EditorGUILayout.Toggle("Enable Post Processing", postProcessing.boolValue);
		if (postProcessing.boolValue) {
			colorDepth.intValue = EditorGUILayout.IntField("Color Depth", colorDepth.intValue);
			subtractFade.intValue = EditorGUILayout.IntSlider("Subtraction Fade", subtractFade.intValue, 0, 100);
			favorRed.floatValue = EditorGUILayout.FloatField("Darken Darks/Favor Red", favorRed.floatValue);
			scanlines.boolValue = EditorGUILayout.Toggle("Scanlines", scanlines.boolValue);
			if (scanlines.boolValue) {
				verticalScanlines.boolValue = EditorGUILayout.Toggle("Vertical", verticalScanlines.boolValue);
				scanlineIntensity.intValue = EditorGUILayout.IntSlider("Scanline Intensity", scanlineIntensity.intValue, 0, 100);
			}
			dithering.boolValue = EditorGUILayout.Toggle("Dithering", dithering.boolValue);
			if (dithering.boolValue) {
				ditherType.objectReferenceValue = EditorGUILayout.ObjectField("Dither Texture", ditherType.objectReferenceValue, typeof(Texture2D), false);
				ditherThreshold.floatValue = EditorGUILayout.FloatField("Dither Threshold", ditherThreshold.floatValue);
				ditherIntensity.intValue = EditorGUILayout.IntSlider("Dither Intensity", ditherIntensity.intValue, 0, 100);
			}
		}

		serializedObject.ApplyModifiedProperties();
	}
}
