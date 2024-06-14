using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class PostProcessingOverlay : MonoBehaviour
{
    public Material postProcessingMaterial;
    public Texture overlayTexture; // New texture
    private CommandBuffer commandBuffer;
    private Vector3 mousePosition = Vector3.zero; // Mouse position

    void OnEnable()
    {
        commandBuffer = new CommandBuffer { name = "PostProcessing" };
        GetComponent<Camera>().AddCommandBuffer(CameraEvent.AfterImageEffects, commandBuffer);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (postProcessingMaterial != null)
        {
            Graphics.Blit(src, dest, postProcessingMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    public void SetEffect(Vector4 mousePosition)
    {
        if (postProcessingMaterial != null)
        {
            postProcessingMaterial.SetVector("_MousePos", mousePosition); // Set the mouse position
            postProcessingMaterial.SetFloat("_OverlayTransparency", 0.5f); // Set the transparency
        }
    }

    public void SetMousePosition(Vector3 pos)
    {
        mousePosition = pos;
    }
}
