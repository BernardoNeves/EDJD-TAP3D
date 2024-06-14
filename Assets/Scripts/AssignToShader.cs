using System.Collections;
using UnityEngine;

public class AssignToShader : MonoBehaviour
{
    // Declaração das variáveis públicas e privadas
    public Material material;
    private CardVisual cardVisual;
    private bool instantiateMaterial = true;
    private bool isGrayscaleMaterial = false;
    private bool isGlitchSpeedMaterial = false;

    // Variáveis para o efeito de glitch
    public float glitchChance = 0.1f; // Chance de ocorrer um glitch
    private WaitForSeconds glitchLoopWait = new WaitForSeconds(0.1f); // Intervalo entre as verificações de glitch
    private Coroutine glitchCoroutine; // Referência à corrotina do efeito de glitch

    private PostProcessingHolo postProcessingManager;
    private PostProcessingOverlay postProcessingOverlay;

    void Start()
    {
        // Obtém o CardVisual e associa eventos de seleção e arraste
        GetComponentInParent<CardVisual>().parentCard.SelectEvent.AddListener(OnSelect);
        cardVisual = GetComponentInParent<CardVisual>();
        cardVisual.parentCard.SelectEvent.AddListener(OnSelect);
        cardVisual.parentCard.BeginDragEvent.AddListener(OnBeginDrag);
        cardVisual.parentCard.EndDragEvent.AddListener(OnEndDrag);

        // Verifica se o material deve ser instanciado
        instantiateMaterial = cardVisual.parentCard.GetComponentInParent<CardHolder>().instantiateMaterial;

        if (instantiateMaterial)
            material = GetComponent<Renderer>().material; // Usa uma instância do material
        else
            material = GetComponent<Renderer>().sharedMaterial; // Usa o material compartilhado

        // Obtém componentes de pós-processamento
        postProcessingManager = Camera.main.GetComponent<PostProcessingHolo>();
        postProcessingOverlay = Camera.main.GetComponent<PostProcessingOverlay>();

        // Verifica se o material tem propriedades específicas
        isGrayscaleMaterial = material.HasProperty("_ApplyGrayscale");
        isGlitchSpeedMaterial = material.HasProperty("_GlitchSpeed");
    }

    void Update()
    {
        // Atualiza a rotação do material
        AssignRotation();
    }

    void AssignRotation()
    {
        // Obtém os ângulos de rotação do pai do cartão
        Vector3 angles = cardVisual.tiltParent.eulerAngles;

        angles.x = NormalizeAngle(angles.x);
        angles.y = NormalizeAngle(angles.y);

        // Define a rotação do cartão no material
        material.SetVector("_CardRotation", new Vector2(-angles.y, angles.x));
    }

    float NormalizeAngle(float angle)
    {
        // Normaliza o ângulo para o intervalo [-180, 180] e converte para uma fração de 360 graus
        while (angle > 180) angle -= 360;
        while (angle < -180) angle += 360;
        return angle / 360;
    }

    void OnMouseEnter()
    {
        // Ativa a propriedade de hovering no material quando o mouse entra
        if (cardVisual.parentCard.isDragging) return;
        material.SetFloat("_MouseHovering", 1);
    }

    void OnMouseOver()
    {
        // Atualiza a posição do mouse no material quando o mouse está sobre o objeto
        if (cardVisual.parentCard.isDragging) return;
        AssignMousePosition();
    }

    void OnMouseExit()
    {
        // Desativa a propriedade de hovering no material quando o mouse sai
        material.SetFloat("_MouseHovering", 0);
        material.SetVector("_MousePosition", new Vector2(0, 0));
    }

    void AssignMousePosition()
    {
        // Calcula a posição do mouse relativa à posição do cartão na tela
        Vector3 mousePos = Input.mousePosition;
        Vector3 cardPos = Camera.main.WorldToScreenPoint(transform.position);

        Vector3 offset = mousePos - cardPos;
        offset.x /= Screen.width;
        offset.y /= Screen.height;

        // Define a posição do mouse no material
        material.SetVector("_MousePosition", new Vector2(offset.x, offset.y));
    }

    void OnSelect(Card card, bool selected)
    {
        // Define a propriedade de seleção no material
        material.SetFloat("_CardSelected", selected ? 1 : 0);
    }

    void OnBeginDrag(Card card)
    {
        // Inicia o efeito de arraste no material e ativa o efeito de glitch, se aplicável
        material.SetFloat("_MouseHovering", 0);
        material.SetFloat("_CardDragging", 1);

        if (isGrayscaleMaterial)
        {
            postProcessingManager.SetBorderEffect(Color.gray, 0.005f, true, true);
            material.SetFloat("_ApplyGrayscale", 0.0f);
        }

        if (isGlitchSpeedMaterial)
        {
            // Inicia a corrotina do efeito de glitch
            if (glitchCoroutine != null)
            {
                StopCoroutine(glitchCoroutine);
            }
            glitchCoroutine = StartCoroutine(GlitchEffect());
        }
    }

    void OnEndDrag(Card card)
    {
        // Finaliza o efeito de arraste no material e desativa o efeito de glitch, se aplicável
        material.SetFloat("_MouseHovering", 0);
        material.SetFloat("_CardDragging", 0);

        if (isGrayscaleMaterial)
        {
            postProcessingManager.SetBorderEffect(Color.clear, 0.0f, false, false);
            material.SetFloat("_ApplyGrayscale", 1.0f);
        }

        if (isGlitchSpeedMaterial)
        {
            // Finaliza a corrotina do efeito de glitch
            if (glitchCoroutine != null)
            {
                StopCoroutine(glitchCoroutine);
                glitchCoroutine = null;

                // Assegura que o efeito de glitch seja resetado
                material.SetFloat("_GlitchIntensity", 0f);
                material.SetFloat("_GlowIntensity", 0.5f); // Reseta para a intensidade de brilho padrão, ajuste conforme necessário
            }
        }

        // Atualiza o efeito de pós-processamento com a posição atual do mouse
        Vector3 mousePos = Input.mousePosition;
        postProcessingOverlay.SetEffect(mousePos);
    }

    // Define uma corrotina que aplica um efeito de glitch a um material
    IEnumerator GlitchEffect()
    {
        // Loop infinito para aplicar o efeito de glitch periodicamente
        while (true)
        {
            // Gera um valor aleatório entre 0 e 1 para testar a aplicação do efeito de glitch
            float glitchTest = Random.Range(0f, 1f);

            // Verifica se o valor gerado é menor ou igual à chance de glitch (glitchChance)
            if (glitchTest <= glitchChance)
            {
                // Aplica o efeito de glitch
                // Armazena o valor original da intensidade do brilho (glow intensity) do material
                float originalGlowIntensity = material.GetFloat("_GlowIntensity");
                // Define a intensidade do glitch para um valor aleatório entre 0.07 e 0.1
                material.SetFloat("_GlitchIntensity", Random.Range(0.07f, 0.1f));
                // Ajusta a intensidade do brilho para um valor aleatório entre 14% e 44% do valor original
                material.SetFloat("_GlowIntensity", originalGlowIntensity * Random.Range(0.14f, 0.44f));
                // Espera por um tempo aleatório entre 0.05 e 0.1 segundos
                yield return new WaitForSeconds(Random.Range(0.05f, 0.1f));
                // Remove o efeito de glitch, redefinindo a intensidade do glitch para 0
                material.SetFloat("_GlitchIntensity", 0f);
                // Restaura a intensidade do brilho para o valor original
                material.SetFloat("_GlowIntensity", originalGlowIntensity);
            }

            // Espera por um tempo pré-definido antes de verificar novamente a chance de aplicar o efeito de glitch
            yield return glitchLoopWait;
        }
    }
}
