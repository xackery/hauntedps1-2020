using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;

public class PS1ShaderEditor : ShaderGUI {

	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
	{
		Material material = materialEditor.target as Material;

		bool transparent = Array.IndexOf(material.shaderKeywords, "TRANSPARENT") != -1;
		bool culling = Array.IndexOf(material.shaderKeywords, "BFC") != -1;
		EditorGUI.BeginChangeCheck();
		transparent = EditorGUILayout.Toggle("Transparent", transparent);
		culling = EditorGUILayout.Toggle("Backface Culling", culling);
		if (EditorGUI.EndChangeCheck()) {
			if (transparent) {
				material.SetOverrideTag("RenderType", "Transparent");
				material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
				material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
				material.DisableKeyword("_ALPHATEST_ON");
				material.EnableKeyword("_ALPHABLEND_ON");
				material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
				material.EnableKeyword("TRANSPARENT");
				material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
			} else {
				material.SetOverrideTag("RenderType", "Opaque");
				material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
				material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
				material.DisableKeyword("_ALPHATEST_ON");
				material.DisableKeyword("_ALPHABLEND_ON");
				material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
				material.DisableKeyword("TRANSPARENT");
				material.renderQueue = -1;
			}
			if (culling) {
				material.SetInt("_Cul", (int)UnityEngine.Rendering.CullMode.Back);
				material.EnableKeyword("BFC");
			} else {
				material.SetInt("_Cul", (int)UnityEngine.Rendering.CullMode.Off);
				material.DisableKeyword("BFC");
			}
		}

		base.OnGUI(materialEditor, properties);
	}
}
