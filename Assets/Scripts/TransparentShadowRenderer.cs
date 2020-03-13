using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (Camera))]
public class TransparentShadowRenderer : MonoBehaviour {

    void OnPreRender () {
        var casters = TransparentShadowManager.instance.GetCasters ();
        foreach (var light in TransparentShadowManager.instance.GetLights ()) {
            light.UpdateMatrix ();
            light.UpdateCommaad (casters);

            Shader.SetGlobalMatrix ("transparentShadow_VP", light.projectionMatrix * light.viewMatrix);
            Shader.SetGlobalTexture ("transparentShadow_map", light.shadowMap);
        }
    }
}