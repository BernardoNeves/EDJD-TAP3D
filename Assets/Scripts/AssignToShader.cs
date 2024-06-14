using System.Collections;
using UnityEngine;

public class AssignToShader : MonoBehaviour
{
    // Declara??o das vari?veis p?blicas e privadas
    public Material material;
    private CardVisual cardVisual;
    private bool instantiateMaterial = true;
    private bool isGrayscaleMaterial = false;
    private bool isGlitchSpeedMaterial = false;

    // Vari?veis para o efeito de glitch
    public float glitchChance = 0.1f; // Chance de ocorrer um glitch
    private WaitForSeconds glitchLoopWait = new WaitForSeconds(0.1f); // Intervalo entre as verifica??es de glitch
    private Coroutine glitchCoroutine; // Refer?ncia ? corrotina do efeito de glitch

    private PostProcessingHolo postProcessingManager;
    private PostProcessingOverlay postProcessingOverlay;

    void Start()
    {
        // Obt?m o CardVisual e associa eventos de sele??o e arraste
        GetComponentInParent<CardVisual>().parentCard.SelectEvent.AddListener(OnSelect);
        cardVisual = GetComponentInParent<CardVisual>();
        cardVisual.parentCard.SelectEvent.AddListener(OnSelect);
        cardVisual.parentCard.BeginDragEvent.AddListener(OnBeginDrag);
        cardVisual.parentCard.EndDragEvent.AddListener(OnEndDrag);

        // Verifica se o material deve ser instanciado
        instantiateMaterial = cardVisual.parentCard.GetComponentInParent<CardHolder>().instantiateMaterial;

        if (instantiateMaterial)
            material = GetComponent<Renderer>().material; // Usa uma inst?ncia do material
        else
            material = GetComponent<Renderer>().sharedMaterial; // Usa o material compartilhado

        // Obt?m componentes de p?s-processamento
        postProcessingManager = Camera.main.GetComponent<PostProcessingHolo>();
        postProcessingOverlay = Camera.main.GetComponent<PostProcessingOverlay>();

        // Verifica se o material tem propriedades espec?ficas
        isGrayscaleMaterial = material.HasProperty("_ApplyGrayscale");
        isGlitchSpeedMaterial = material.HasProperty("_GlitchSpeed");
    }

    void Update()
    {
        // Atualiza a rota??o do material
        AssignRotation();
    }

    void AssignRotation()
    {
        // Obt?m os ?ngulos de rota??o do pai do cart?o
        Vector3 angles = cardVisual.tiltParent.eulerAngles;

        angles.x = NormalizeAngle(angles.x);
        angles.y = NormalizeAngle(angles.y);

        // Define a rota??o do cart?o no material
        material.SetVector("_CardRotation", new Vector2(-angles.y, angles.x));
    }

    float NormalizeAngle(float angle)
    {
        // Normaliza o ?ngulo para o intervalo [-180, 180] e converte para uma fra??o de 360 graus
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
        // Atualiza a posi??o do mouse no material quando o mouse est? sobre o objeto
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
        // Calcula a posi??o do mouse relativa ? posi??o do cart?o na tela
        Vector3 mousePos = Input.mousePosition;
        Vector3 cardPos = Camera.main.WorldToScreenPoint(transform.position);

        Vector3 offset = mousePos - cardPos;
        offset.x /= Screen.width;
        offset.y /= Screen.height;

        // Define a posi??o do mouse no material
        material.SetVector("_MousePosition", new Vector2(offset.x, offset.y));
    }

    void OnSelect(Card card, bool selected)
    {
        // Define a propriedade de sele??o no material
        material.SetFloat("_CardSelected", selected ? 1 : 0);
    }

    void OnBeginDrag(Card card)
    {
        // Inicia o efeito de arraste no material e ativa o efeito de glitch, se aplic?vel
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
        // Finaliza o efeito de arraste no material e desativa o efeito de glitch, se aplic?vel
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
                material.SetFloat("_GlowIntensity", 0.5f); // Reseta para a intensidade de brilho padr?o, ajuste conforme necess?rio
            }
        }
    }

    // Define uma corrotina que aplica um efeito de glitch a um material
    IEnumerator GlitchEffect()
    {
        // Loop infinito para aplicar o efeito de glitch periodicamente
        while (true)
        {
            // Gera um valor aleat?rio entre 0 e 1 para testar a aplica??o do efeito de glitch
            float glitchTest = Random.Range(0f, 1f);

            // Verifica se o valor gerado ? menor ou igual ? chance de glitch (glitchChance)
            if (glitchTest <= glitchChance)
            {
                // Aplica o efeito de glitch
                // Armazena o valor original da intensidade do brilho (glow intensity) do material
                float originalGlowIntensity = material.GetFloat("_GlowIntensity");
                // Define a intensidade do glitch para um valor aleat?rio entre 0.07 e 0.1
                material.SetFloat("_GlitchIntensity", Random.Range(0.07f, 0.1f));
                // Ajusta a intensidade do brilho para um valor aleat?rio entre 14% e 44% do valor original
                material.SetFloat("_GlowIntensity", originalGlowIntensity * Random.Range(0.14f, 0.44f));
                // Espera por um tempo aleat?rio entre 0.05 e 0.1 segundos
                yield return new WaitForSeconds(Random.Range(0.05f, 0.1f));
                // Remove o efeito de glitch, redefinindo a intensidade do glitch para 0
                material.SetFloat("_GlitchIntensity", 0f);
                // Restaura a intensidade do brilho para o valor original
                material.SetFloat("_GlowIntensity", originalGlowIntensity);
            }

            // Espera por um tempo pr?-definido antes de verificar novamente a chance de aplicar o efeito de glitch
            yield return glitchLoopWait;
        }
    }
}
