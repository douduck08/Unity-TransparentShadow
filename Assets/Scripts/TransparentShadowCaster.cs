using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (Renderer))]
public class TransparentShadowCaster : MonoBehaviour {

    [SerializeField] Shader shader;
    [SerializeField] Color color;

    Material _material;
    Renderer _renderer;

    public new Renderer renderer {
        get {
            return _renderer;
        }
    }

    public Material material {
        get {
            return _material;
        }
    }

    void OnEnable () {
        TransparentShadowManager.instance.Register (this);

        if (_renderer == null) {
            _renderer = GetComponent<Renderer> ();
        }
    }

    void OnDisable () {
        TransparentShadowManager.instance.Unregister (this);
    }

    void Update () {
        UpdateMaterial ();
    }

    void UpdateMaterial () {
        if (_material == null) {
            _material = new Material (shader);
        }
        _material.SetColor ("_Color", color);
    }

}