using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent (typeof (Light))]
public class TransparentShadowLight : MonoBehaviour {

    public Material blendMaterial;

    new Light light;

    CommandBuffer afterShadowMapCommand;
    CommandBuffer renderColorBufferCommand;
    CommandBuffer blendShadowMaskCommand;

    RenderTexture coloredShadow;
    RenderTexture coloredShadowDepth;
    Matrix4x4 viewMatrix;
    Matrix4x4 projMatrix;

    void OnEnable () {
        TransparentShadowManager.instance.Register (this);
        light = GetComponent<Light> ();
    }

    void OnDisable () {
        TransparentShadowManager.instance.Unregister (this);
        light = GetComponent<Light> ();
        ReleaseResource ();
    }

    public void CheckResourceSettings (int resolution, float orthoSize, float zNear = 0.3f, float zFar = 100f) {
        if (light.type == LightType.Directional) {
            projMatrix = Matrix4x4.Ortho (-orthoSize, orthoSize, -orthoSize, orthoSize, zNear, zFar);
            // projMatrix = GL.GetGPUProjectionMatrix (projMatrix, true);

            viewMatrix = Matrix4x4.Inverse (Matrix4x4.TRS (
                this.transform.position,
                this.transform.rotation,
                new Vector3 (1, 1, -1)
            ));

            if (coloredShadow == null) {
                coloredShadow = new RenderTexture (resolution, resolution, 0, RenderTextureFormat.ARGB32);
                coloredShadow.name = "Transparent Shadow Map";
            }

            if (coloredShadowDepth == null) {
                coloredShadowDepth = new RenderTexture (resolution, resolution, 0, RenderTextureFormat.Depth);
                coloredShadowDepth.name = "Transparent Shadow Depth";
            }

            if (afterShadowMapCommand == null) {
                afterShadowMapCommand = new CommandBuffer ();
                afterShadowMapCommand.name = "Transparent Shadow";
                afterShadowMapCommand.SetGlobalTexture ("_CascadeShadowMapTexture", BuiltinRenderTextureType.CurrentActive);
                light.AddCommandBuffer (LightEvent.AfterShadowMap, afterShadowMapCommand);
            }

            if (renderColorBufferCommand == null) {
                renderColorBufferCommand = new CommandBuffer ();
                renderColorBufferCommand.name = "Transparent Shadow: Render to Buffers";
                light.AddCommandBuffer (LightEvent.BeforeScreenspaceMask, renderColorBufferCommand);
            }

            if (blendShadowMaskCommand == null) {
                blendShadowMaskCommand = new CommandBuffer ();
                blendShadowMaskCommand.name = "Transparent Shadow: Blend Shadow Mask";
                light.AddCommandBuffer (LightEvent.AfterScreenspaceMask, blendShadowMaskCommand);
            }
        }
    }

    void ReleaseResource () {
        if (coloredShadow != null) {
            coloredShadow.Release ();
            coloredShadow = null;
        }

        if (coloredShadowDepth != null) {
            coloredShadowDepth.Release ();
            coloredShadowDepth = null;
        }

        if (afterShadowMapCommand != null) {
            light.RemoveCommandBuffer (LightEvent.AfterShadowMap, afterShadowMapCommand);
            afterShadowMapCommand = null;
        }

        if (renderColorBufferCommand != null) {
            light.RemoveCommandBuffer (LightEvent.BeforeScreenspaceMask, renderColorBufferCommand);
            renderColorBufferCommand = null;
        }

        if (blendShadowMaskCommand != null) {
            light.RemoveCommandBuffer (LightEvent.AfterScreenspaceMask, blendShadowMaskCommand);
            blendShadowMaskCommand = null;
        }
    }

    public void UpdateCommand (IEnumerable<TransparentShadowCaster> casters, Matrix4x4 cameraFrustumCorners) {
        var matrix_VP = projMatrix * viewMatrix;

        renderColorBufferCommand.Clear ();
        renderColorBufferCommand.SetRenderTarget (coloredShadow.colorBuffer, coloredShadowDepth.depthBuffer);
        renderColorBufferCommand.ClearRenderTarget (true, true, new Color (1, 1, 1, 0));
        renderColorBufferCommand.SetViewProjectionMatrices (viewMatrix, projMatrix);
        foreach (var caster in casters) {
            renderColorBufferCommand.DrawRenderer (caster.renderer, caster.material);
        }

        blendMaterial.SetMatrix ("cameraFrustumCorners", cameraFrustumCorners);
        blendShadowMaskCommand.Clear ();
        blendShadowMaskCommand.SetGlobalMatrix ("transparentShadow_VP", matrix_VP);
        blendShadowMaskCommand.SetGlobalTexture ("transparentShadow_map", coloredShadow);
        blendShadowMaskCommand.SetGlobalTexture ("transparentShadow_depth", coloredShadowDepth);
        // TODO: blendShadowMaskCommand.Blit (BuiltinRenderTextureType.None, BuiltinRenderTextureType.CurrentActive, blendMaterial, 1);
    }
}