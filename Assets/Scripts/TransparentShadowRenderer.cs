using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof (Camera))]
public class TransparentShadowRenderer : MonoBehaviour {

    [SerializeField] int bufferSize = 1024;
    [SerializeField] float orthoSize = 5f;

    Camera renderCamera;
    Vector3[] frustumCorners = new Vector3[4];
    Matrix4x4 cameraFrustumCorners;

    void OnPreRender () {
        UpdateFrustumCorners ();
        var casters = TransparentShadowManager.instance.GetCasters ();
        foreach (var light in TransparentShadowManager.instance.GetLights ()) {
            light.CheckResourceSettings (bufferSize, orthoSize);
            light.UpdateCommand (casters, cameraFrustumCorners, renderCamera);
        }
    }

    void UpdateFrustumCorners () {
        if (renderCamera == null) {
            renderCamera = GetComponent<Camera> ();
        }

        renderCamera.CalculateFrustumCorners (new Rect (0, 0, 1, 1), renderCamera.farClipPlane, Camera.MonoOrStereoscopicEye.Mono, frustumCorners);
        cameraFrustumCorners.SetRow (0, transform.localToWorldMatrix.MultiplyVector (Vector3.Normalize (frustumCorners[0])));
        cameraFrustumCorners.SetRow (1, transform.localToWorldMatrix.MultiplyVector (Vector3.Normalize (frustumCorners[1])));
        cameraFrustumCorners.SetRow (2, transform.localToWorldMatrix.MultiplyVector (Vector3.Normalize (frustumCorners[2])));
        cameraFrustumCorners.SetRow (3, transform.localToWorldMatrix.MultiplyVector (Vector3.Normalize (frustumCorners[3])));
    }
}