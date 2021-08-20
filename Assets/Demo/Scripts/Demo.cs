using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Demo : MonoBehaviour
{
    public Transform prefab;
    [Range(0, 1)]
    public float alphaMix = 1;
    private List<LayerBlend> layerBlends = new List<LayerBlend>();

    private void Start()
    {
        foreach (LayerStyle layerStyle in Enum.GetValues(typeof(LayerStyle)))
        {
            Transform t = Instantiate(prefab, prefab.parent);
            LayerBlend lb = t.GetChild(0).GetChild(0).GetComponent<LayerBlend>();
            layerBlends.Add(lb);
            lb.LayerStyle = layerStyle;
            t.GetChild(1).GetComponent<Text>().text = layerStyle.ToString();
        }
        prefab.gameObject.SetActive(false);
    }

    private void Update()
    {
        foreach (var lb in layerBlends)
        {
            lb.AlphaMix = alphaMix;
        }
    }

}
