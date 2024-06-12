using UnityEngine;

public class AssignToShader: MonoBehaviour
{
    public Material material;
    private CardVisual cardVisual;

    void Start()
    {
        material = GetComponent<Renderer>().material;
        cardVisual = GetComponentInParent<CardVisual>();
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

        material.SetVector("_Rotation", new Vector2(-angles.y, angles.x));
    }

    float NormalizeAngle(float angle)
    {
        while (angle > 180) angle -= 360;
        while (angle < -180) angle += 360;
        return angle/360;
    }


    void OnMouseOver()
    {
        AssignMousePosition();
    }

    void OnMouseExit()
    {
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

}


