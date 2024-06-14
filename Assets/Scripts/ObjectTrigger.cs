using UnityEngine;

public class ObjectTrigger : MonoBehaviour
{
    public Pixilate pixilate;

    void OnMouseDown()
    {
        if (pixilate != null)
        {
            pixilate.TriggerPixelate();
        }
    }
}

