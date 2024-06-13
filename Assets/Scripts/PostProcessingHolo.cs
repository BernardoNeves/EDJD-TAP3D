using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class PostProcessingHolo : MonoBehaviour
{
    public Material postProcessingMaterial;
    private CommandBuffer commandBuffer;

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

    public void SetBorderEffect(Color color, float thickness, bool applyGrayscale)
    {
        if (postProcessingMaterial != null)
        {
            postProcessingMaterial.SetColor("_BorderColor", color);
            postProcessingMaterial.SetFloat("_BorderThickness", thickness);
            postProcessingMaterial.SetFloat("_ApplyGrayscale", applyGrayscale ? 1.0f : 0.0f);
        }
    }
}
