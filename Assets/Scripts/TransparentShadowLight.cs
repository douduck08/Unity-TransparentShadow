using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent (typeof (Light))]
public class TransparentShadowLight : MonoBehaviour {

    CommandBuffer command;
    RenderTexture coloredShadowBuffer;
    Matrix4x4 _viewMatrix;
    Matrix4x4 _projMatrix;

    public RenderTexture shadowMap {
        get {
            return coloredShadowBuffer;
        }
    }

    public Matrix4x4 viewMatrix {
        get {
            return _viewMatrix;
        }
    }

    public Matrix4x4 projectionMatrix {
        get {
            return _projMatrix;
        }
    }

    void OnEnable () {
        TransparentShadowManager.instance.Register (this);
        CheckResource ();
    }

    void OnDisable () {
        TransparentShadowManager.instance.Unregister (this);
        ReleaseResource ();
    }

    void CheckResource () {
        var light = GetComponent<Light> ();
        if (light.type == LightType.Directional) {
            if (coloredShadowBuffer == null) {
                coloredShadowBuffer = new RenderTexture (1024, 1024, 0, RenderTextureFormat.ARGB32);
            }

            if (command == null) {
                command = new CommandBuffer ();
                command.name = "Transparent Shadow";
            }
            light.AddCommandBuffer (LightEvent.AfterScreenspaceMask, command);
        }
    }

    void ReleaseResource () {
        var light = GetComponent<Light> ();

        if (coloredShadowBuffer != null) {
            coloredShadowBuffer.Release ();
            coloredShadowBuffer = null;
        }

        if (command != null) {
            light.RemoveCommandBuffer (LightEvent.AfterScreenspaceMask, command);
        }
    }

    public void UpdateCommaad (List<TransparentShadowCaster> casters) {
        command.Clear ();
        command.SetRenderTarget (coloredShadowBuffer);
        command.ClearRenderTarget (false, true, new Color (1, 1, 1, 0));
        command.SetViewProjectionMatrices (_viewMatrix, _projMatrix);
        foreach (var caster in casters) {
            command.DrawRenderer (caster.renderer, caster.material);
        }
    }

    public void UpdateMatrix () {
        var orthoSize = 5f;
        _projMatrix = Matrix4x4.Ortho (-orthoSize, orthoSize, -orthoSize, orthoSize, 0.3f, 1000);
        // projMatrix = GL.GetGPUProjectionMatrix (projMatrix, true);

        _viewMatrix = Matrix4x4.Inverse (Matrix4x4.TRS (
            this.transform.position,
            this.transform.rotation,
            new Vector3 (1, 1, -1)
        ));
    }
}