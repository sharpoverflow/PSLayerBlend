using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

#if UNITY_EDITOR
using UnityEditor;
#endif

public enum LayerStyle
{
    Clear,
    Dissolve,
    IgnoreAlpha,

    Darken,
    Multiply,
    ColorBurn,
    LinearBurn,
    DarkerColor,

    Lighten,
    Screen,
    ColorDodge,
    LinearDodge,
    LighterColor,

    Overlay,
    SoftLight,
    HardLight,
    VividLight,
    LinearLight,
    PinLight,
    HardMix,

    Difference,
    Exclusion,
    Subtract,
    Divide,

    Hue,
    Saturation,
    Color,
    Luminosity,
}

[ExecuteInEditMode]
[DisallowMultipleComponent]
[RequireComponent(typeof(Graphic))]
public class LayerBlend : MonoBehaviour, IMaterialModifier
{
    private Material material;
    private Graphic graphic;

    [SerializeField]
    private LayerStyle layerStyle;
    public LayerStyle LayerStyle
    {
        get => layerStyle;
        set
        {
            if (value != layerStyle)
            {
                layerStyle = value;
                UpdateStyle();
            }
        }
    }

    [SerializeField]
    [Range(0.0f, 1.0f)]
    private float alphaMix = 1;
    public float AlphaMix
    {
        get => alphaMix;
        set
        {
            if(value != alphaMix)
            {
                alphaMix = value;
                material.SetFloat("_AlphaMix", alphaMix);
            }
        }
    }

    public void UpdateStyle()
    {
        if (material == null) return;
        Shader shader = FindShader();
        if (shader == null) return;      
        material.shader = shader;
        material.SetFloat("_AlphaMix", alphaMix);
    }

    private void Awake()
    {
        graphic = GetComponent<Graphic>();
    }

    public Shader FindShader()
    {
        string path = "UI/Photoshop/" + layerStyle;
        Shader shader = Shader.Find(path);
        if(shader == null)
        {
            Debug.LogError($"Shader: [{path}] not found");
        }
        return shader;
    }

    Material IMaterialModifier.GetModifiedMaterial(Material baseMaterial)
    {
        if (material == null)
        {
            Shader shader = FindShader();
            if (shader == null)
            {
                return baseMaterial;
            }
            material = new Material(shader) { hideFlags = HideFlags.DontSave | HideFlags.NotEditable };
            material.SetFloat("_AlphaMix", alphaMix);
        }
        return material;
    }

    private void OnDestroy()
    {
        if (material != null)
        {
            DestroyImmediate(material);
            material = null;
            graphic.SetMaterialDirty();
        }
    }

    private void OnEnable()
    {
        graphic.SetMaterialDirty();
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(LayerBlend))]
[CanEditMultipleObjects]
public class LayerBlendEditor : Editor
{
    private static readonly Dictionary<LayerStyle, string> StyleOptionMapping = new Dictionary<LayerStyle, string>
    {
        { LayerStyle.Clear,        "Clear\t清除"},
        { LayerStyle.Dissolve,      "Dissolve\t溶解"},
        { LayerStyle.IgnoreAlpha,   "IgnoreAlpha\t忽略透明"},
        { (LayerStyle)(0xfff1),         "----------" },
        { LayerStyle.Darken,        "Darken\t变暗"},
        { LayerStyle.Multiply,      "Multiply\t正片叠底"},
        { LayerStyle.ColorBurn,     "ColorBurn\t颜色加深"},
        { LayerStyle.LinearBurn,    "LinearBurn\t线性加深"},
        { LayerStyle.DarkerColor,   "DarkerColor\t深色"},
        { (LayerStyle)(0xfff2),        "----------" },
        { LayerStyle.Lighten,       "Lighten\t变亮"},
        { LayerStyle.Screen,        "Screen\t滤色"},
        { LayerStyle.ColorDodge,    "ColorDodge\t颜色减淡"},
        { LayerStyle.LinearDodge,   "LinearDodge\t线性减淡（添加）"},
        { LayerStyle.LighterColor,  "LighterColor\t浅色"},
        { (LayerStyle)(0xfff3),         "----------" },
        { LayerStyle.Overlay,       "Overlay\t叠加"},
        { LayerStyle.SoftLight,     "SoftLight\t柔光"},
        { LayerStyle.HardLight,     "HardLight\t强光"},
        { LayerStyle.VividLight,    "VividLight\t亮光"},
        { LayerStyle.LinearLight,   "LinearLight\t线性光"},
        { LayerStyle.PinLight,      "PinLight\t点光"},
        { LayerStyle.HardMix,       "HardMix\t实色混合"},
        { (LayerStyle)(0xfff4),         "----------" },
        { LayerStyle.Difference,    "Difference\t差值"},
        { LayerStyle.Exclusion,     "Exclusion\t排除"},
        { LayerStyle.Subtract,      "Subtract\t减去"},
        { LayerStyle.Divide,        "Divide\t划分"},
        { (LayerStyle)(0xfff5),         "----------" },
        { LayerStyle.Hue,           "Hue\t色相"},
        { LayerStyle.Saturation,    "Saturation\t饱和度"},
        { LayerStyle.Color,         "Color\t颜色"},
        { LayerStyle.Luminosity,    "Luminosity\t明度"},
    };

    private SerializedProperty layerStyle;
    private SerializedProperty alphaMix;
    private LayerBlend layerBlend;

    protected void OnEnable()
    {
        layerBlend = serializedObject.targetObject as LayerBlend;

        layerStyle = serializedObject.FindProperty("layerStyle");
        alphaMix = serializedObject.FindProperty("alphaMix");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        LayerStyle style = (LayerStyle)layerStyle.intValue;
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Style", GUILayout.Width(100));

        if (EditorGUILayout.DropdownButton(new GUIContent(StyleOptionMapping[style]), FocusType.Keyboard))
        {
            GenericMenu genericMenu = new GenericMenu();

            foreach (var kv in StyleOptionMapping)
            {
                if (kv.Value == "----------")
                {
                    genericMenu.AddSeparator("");
                }
                else
                {
                    GenericMenuAddItem(genericMenu, kv.Value, kv.Key);
                }
            }

            genericMenu.ShowAsContext();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("AlphaMix", GUILayout.Width(100));
        float alphaMixValue = EditorGUILayout.Slider(alphaMix.floatValue, 0, 1);
        if(alphaMixValue != layerBlend.AlphaMix)
        {
            layerBlend.AlphaMix = alphaMixValue;
            EditorUtility.SetDirty(layerBlend);
        }
        EditorGUILayout.EndHorizontal();

        serializedObject.ApplyModifiedProperties();
    }

    private void GenericMenuAddItem(GenericMenu genericMenu, string name, LayerStyle style)
    {
        genericMenu.AddItem(new GUIContent(name), style == (LayerStyle)layerStyle.intValue, () =>
        {
            layerStyle.intValue = (int)style;
            serializedObject.ApplyModifiedProperties();
            layerBlend.UpdateStyle();
        });
    }

}
#endif