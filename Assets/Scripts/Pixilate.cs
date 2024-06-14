using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class Pixilate : MonoBehaviour
{
    public Material effectMaterial;  // Material que contém o shader de pixelização
    [Range(0, 1)]
    public float pixelization = 1.0f;  // Nível de pixelização, variando de 0 a 1
    [Range(0, 1)]
    public float pixelizationChangeSpeed = 0.5f;  // Velocidade de mudança do nível de pixelização
    private Coroutine pixelizationCoroutine;  // Referência para a corrotina de transição de pixelização

    // Função chamada quando a imagem da câmara é renderizada
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effectMaterial != null)
        {
            // Define o valor de pixelização no material do efeito
            effectMaterial.SetFloat("_Pixelization", pixelization);
            // Aplica o material do efeito na imagem renderizada
            Graphics.Blit(source, destination, effectMaterial);
        }
        else
        {
            // Se não houver material do efeito, apenas copia a imagem original
            Graphics.Blit(source, destination);
        }
    }

    // Corrotina para a transição do efeito de pixelização
    IEnumerator PixelizationTransition()
    {
        // Aumenta gradualmente a pixelização até 1.0
        while (pixelization < 1.0f)
        {
            pixelization += Time.deltaTime * pixelizationChangeSpeed;
            if (pixelization > 1.0f)
            {
                pixelization = 1.0f;
            }
            yield return null;
        }

        // Aguarda 1 segundo com a pixelização no máximo
        yield return new WaitForSeconds(1.0f);

        // Diminui gradualmente a pixelização até 0.0
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

    // Função para iniciar a transição de pixelização
    public void TriggerPixelate()
    {
        if (pixelizationCoroutine != null)
        {
            // Para a corrotina anterior se estiver a correr
            StopCoroutine(pixelizationCoroutine);
        }
        // Inicia a corrotina de transição de pixelização
        pixelizationCoroutine = StartCoroutine(PixelizationTransition());
    }
}

