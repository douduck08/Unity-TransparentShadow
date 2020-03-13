using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (Renderer))]
public class TransparentShadowCaster : MonoBehaviour {

    [SerializeField] Material _material;
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

}