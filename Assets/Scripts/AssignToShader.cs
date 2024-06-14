using System.Collections;
using UnityEngine;

public class AssignToShader : MonoBehaviour
{
    public Material material;
    private CardVisual cardVisual;
    private bool instantiateMaterial = true;
    private bool isGrayscaleMaterial = false;
    private bool isGlitchSpeedMaterial = false;

    // Glitch effect variables
    public float glitchChance = 0.1f;
    private WaitForSeconds glitchLoopWait = new WaitForSeconds(0.1f);
    private Coroutine glitchCoroutine;
    
    private PostProcessingHolo postProcessingManager;
    private PostProcessingOverlay postProcessingOverlay;

    void Start()
    {
        GetComponentInParent<CardVisual>().parentCard.SelectEvent.AddListener(OnSelect);
        cardVisual = GetComponentInParent<CardVisual>();
        cardVisual.parentCard.SelectEvent.AddListener(OnSelect);
        cardVisual.parentCard.BeginDragEvent.AddListener(OnBeginDrag);
        cardVisual.parentCard.EndDragEvent.AddListener(OnEndDrag);
        instantiateMaterial = cardVisual.parentCard.GetComponentInParent<CardHolder>().instantiateMaterial;

        if (instantiateMaterial)
            material = GetComponent<Renderer>().material;
        else
            material = GetComponent<Renderer>().sharedMaterial;

        postProcessingManager = Camera.main.GetComponent<PostProcessingHolo>();
        postProcessingOverlay = Camera.main.GetComponent<PostProcessingOverlay>();

        isGrayscaleMaterial = material.HasProperty("_ApplyGrayscale");
        isGlitchSpeedMaterial = material.HasProperty("_GlitchSpeed");
    }

    void Update()
    {
        AssignRotation();
    }

    void AssignRotation()
    {
        Vector3 angles = cardVisual.tiltParent.eulerAngles;

        angles.x = NormalizeAngle(angles.x);
        angles.y = NormalizeAngle(angles.y);

        material.SetVector("_CardRotation", new Vector2(-angles.y, angles.x));
    }

    float NormalizeAngle(float angle)
    {
        while (angle > 180) angle -= 360;
        while (angle < -180) angle += 360;
        return angle / 360;
    }

    void OnMouseEnter()
    {
        if (cardVisual.parentCard.isDragging) return;
        material.SetFloat("_MouseHovering", 1);
    }

    void OnMouseOver()
    {
        if (cardVisual.parentCard.isDragging) return;
        AssignMousePosition();
    }

    void OnMouseExit()
    {
        material.SetFloat("_MouseHovering", 0);
        material.SetVector("_MousePosition", new Vector2(0, 0));
    }

    void AssignMousePosition()
    {
        Vector3 mousePos = Input.mousePosition;
        Vector3 cardPos = Camera.main.WorldToScreenPoint(transform.position);

        Vector3 offset = mousePos - cardPos;
        offset.x /= Screen.width;
        offset.y /= Screen.height;

        material.SetVector("_MousePosition", new Vector2(offset.x, offset.y));
    }

    void OnSelect(Card card, bool selected)
    {
        material.SetFloat("_CardSelected", selected ? 1 : 0);
    }

    void OnBeginDrag(Card card)
    {
        material.SetFloat("_MouseHovering", 0);
        material.SetFloat("_CardDragging", 1);

        if (isGrayscaleMaterial)
        {
            postProcessingManager.SetBorderEffect(Color.gray, 0.005f, true, true);
            material.SetFloat("_ApplyGrayscale", 0.0f);
        }

        if (isGlitchSpeedMaterial)
        {
            // Start the glitch effect coroutine
            if (glitchCoroutine != null)
            {
                StopCoroutine(glitchCoroutine);
            }
            glitchCoroutine = StartCoroutine(GlitchEffect());
        }
    }

    void OnEndDrag(Card card)
    {
        material.SetFloat("_MouseHovering", 0);
        material.SetFloat("_CardDragging", 0);

        if (isGrayscaleMaterial)
        {
            postProcessingManager.SetBorderEffect(Color.clear, 0.0f, false, false);
            material.SetFloat("_ApplyGrayscale", 1.0f);
        }

        if (isGlitchSpeedMaterial)
        {
            // Stop the glitch effect coroutine
            if (glitchCoroutine != null)
            {
                StopCoroutine(glitchCoroutine);
                glitchCoroutine = null;

                // Ensure glitch effect is reset
                material.SetFloat("_GlitchIntensity", 0f);
                material.SetFloat("_GlowIntensity", 0.5f); // Reset to default glow intensity, adjust as necessary
            }
        }

        Vector3 mousePos = Input.mousePosition;

        postProcessingOverlay.SetEffect(mousePos);
    }

    IEnumerator GlitchEffect()
    {
        while (true)
        {
            float glitchTest = Random.Range(0f, 1f);

            if (glitchTest <= glitchChance)
            {
                // Apply glitch effect
                float originalGlowIntensity = material.GetFloat("_GlowIntensity");
                material.SetFloat("_GlitchIntensity", Random.Range(0.07f, 0.1f));
                material.SetFloat("_GlowIntensity", originalGlowIntensity * Random.Range(0.14f, 0.44f));
                yield return new WaitForSeconds(Random.Range(0.05f, 0.1f));
                material.SetFloat("_GlitchIntensity", 0f);
                material.SetFloat("_GlowIntensity", originalGlowIntensity);
            }

            yield return glitchLoopWait;
        }
    }
}
