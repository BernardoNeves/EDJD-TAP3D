using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class Pixilate : MonoBehaviour
{
    public Material effectMaterial;
    [Range(0, 1)]
    public float pixelization = 1.0f;
    [Range(0, 1)]
    public float pixelizationChangeSpeed = 0.5f;
    private Coroutine pixelizationCoroutine;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effectMaterial != null)
        {
            effectMaterial.SetFloat("_Pixelization", pixelization);
            Graphics.Blit(source, destination, effectMaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    IEnumerator PixelizationTransition()
    {
        while (pixelization < 1.0f)
        {
            pixelization += Time.deltaTime * pixelizationChangeSpeed;
            if (pixelization > 1.0f)
            {
                pixelization = 1.0f;
            }
            yield return null;
        }

        yield return new WaitForSeconds(1.0f);

        while (pixelization > 0.0f)
        {
            pixelization -= Time.deltaTime * pixelizationChangeSpeed;
            if (pixelization < 0.0f)
            {
                pixelization = 0.0f;
            }
            yield return null;
        }
    }

    public void TriggerPixelate()
    {
        if (pixelizationCoroutine != null)
        {
            StopCoroutine(pixelizationCoroutine);
        }
        pixelizationCoroutine = StartCoroutine(PixelizationTransition());
    }
}

