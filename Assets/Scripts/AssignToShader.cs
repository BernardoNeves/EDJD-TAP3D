using UnityEngine;

public class AssignToShader: MonoBehaviour
{
    public Material material;
    private CardVisual cardVisual;
    private bool instantiateMaterial = true;

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
        return angle/360;
    }

    void OnMouseEnter()
    {
        if (cardVisual.parentCard.isDragging) return;
        material.SetFloat("_MouseHovering", 1);
    }

    void OnMouseOver()
    {
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
    }

    void OnEndDrag(Card card)
    {
        material.SetFloat("_MouseHovering", 0);
        material.SetFloat("_CardDragging", 0);
    }

}
