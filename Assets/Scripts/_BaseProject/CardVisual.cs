using System;
using UnityEngine;
using DG.Tweening;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class CardVisual : MonoBehaviour
{
    private bool initialized = false;

    [Header("Card")]
    public Card parentCard;
    private Transform cardTransform;
    private Vector3 rotationDelta;
    private Vector3 movementDelta;
    private Canvas canvas;

    [Header("References")]
    public Transform visualShadow;
    private float shadowOffset = 20f;
    private Vector2 shadowDistance;
    private Canvas shadowCanvas;
    [SerializeField] private Transform shakeParent;
    [SerializeField] public Transform tiltParent;
    [SerializeField] private Image cardImage;
    [SerializeField] private MeshRenderer cardMesh;

    [Header("Follow Parameters")]
    [SerializeField] private float followSpeed = 30f;

    [Header("Rotation Parameters")]
    [SerializeField] private float rotationAmount = 20f;
    [SerializeField] private float rotationSpeed = 20f;
    [SerializeField] private float autoTiltAmount = 30f;
    [SerializeField] private float manualTiltAmount = 20f;
    [SerializeField] private float tiltSpeed = 20f;

    [Header("Scale Parameters")]
    [SerializeField] private bool scaleAnimations = true;
    [SerializeField] private float scaleOnHover = 1.15f;
    [SerializeField] private float scaleOnSelect = 1.25f;
    [SerializeField] private float scaleTransition = 0.15f;
    [SerializeField] private Ease scaleEase = Ease.OutBack;

    [Header("Select Parameters")]
    [SerializeField] private float selectPunchAmount = 20f;

    [Header("Hover Parameters")]
    [SerializeField] private float hoverPunchAngle = 5f;
    [SerializeField] private float hoverTransition = 0.15f;

    [Header("Swap Parameters")]
    [SerializeField] private bool swapAnimations = true;
    [SerializeField] private float swapRotationAngle = 30f;
    [SerializeField] private float swapTransition = 0.15f;
    [SerializeField] private int swapVibrato = 5;

    [Header("Curve")]
    [SerializeField] private CurveParameters curve;

    private float curveYOffset;
    private float curveRotationOffset;

    private void Start()
    {
        shadowDistance = visualShadow.localPosition;
    }

    public void Initialize(Card target, int index = 0, Material material = null)
    {
        parentCard = target;
        cardTransform = target.transform;
        canvas = GetComponent<Canvas>();
        shadowCanvas = visualShadow.GetComponent<Canvas>();

        SubscribeToCardEvents();

        if (cardImage != null && material != null)
            cardImage.material = material;
        else if (cardMesh != null && material != null)
            cardMesh.material = material;

        initialized = true;
    }

    private void SubscribeToCardEvents()
    {
        parentCard.PointerEnterEvent.AddListener(PointerEnter);
        parentCard.PointerExitEvent.AddListener(PointerExit);
        parentCard.BeginDragEvent.AddListener(BeginDrag);
        parentCard.EndDragEvent.AddListener(EndDrag);
        parentCard.PointerDownEvent.AddListener(PointerDown);
        parentCard.PointerUpEvent.AddListener(PointerUp);
        parentCard.SelectEvent.AddListener(Select);
    }

    public void UpdateIndex(int length)
    {
        transform.SetSiblingIndex(parentCard.transform.parent.GetSiblingIndex());
    }

    private void Update()
    {
        if (!initialized || parentCard == null) return;

        UpdateHandPositioning();
        SmoothFollow();
        UpdateFollowRotation();
        UpdateCardTilt();
    }

    private void UpdateHandPositioning()
    {
        curveYOffset = (curve.positioning.Evaluate(parentCard.NormalizedPosition()) * curve.positioningInfluence) * parentCard.SiblingAmount();
        curveYOffset = parentCard.SiblingAmount() < 5 ? 0 : curveYOffset;
        curveRotationOffset = curve.rotation.Evaluate(parentCard.NormalizedPosition());
    }

    private void SmoothFollow()
    {
        Vector3 verticalOffset = Vector3.up * (parentCard.isDragging ? 0 : curveYOffset);
        transform.position = Vector3.Lerp(transform.position, cardTransform.position + verticalOffset, followSpeed * Time.deltaTime);
    }

    private void UpdateFollowRotation()
    {
        Vector3 movement = transform.position - cardTransform.position;
        movementDelta = Vector3.Lerp(movementDelta, movement, 25 * Time.deltaTime);
        Vector3 movementRotation = parentCard.isDragging ? movementDelta : movement;
        movementRotation *= rotationAmount;
        rotationDelta = Vector3.Lerp(rotationDelta, movementRotation, rotationSpeed * Time.deltaTime);
        transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y, Mathf.Clamp(rotationDelta.x, -60, 60));
    }

    private void UpdateCardTilt()
    {
        if (parentCard.isDragging) return;
        int savedIndex = parentCard.isDragging ? 0 : parentCard.ParentIndex();
        float sine = Mathf.Sin(Time.time + savedIndex) * (parentCard.isHovering ? 0.2f : 1);
        float cosine = Mathf.Cos(Time.time + savedIndex) * (parentCard.isHovering ? 0.2f : 1);

        Vector3 offset = transform.position - Camera.main.ScreenToWorldPoint(Input.mousePosition);
        float tiltX = parentCard.isHovering ? (-offset.y * manualTiltAmount) : 0;
        float tiltY = parentCard.isHovering ? (offset.x * manualTiltAmount) : 0;
        float tiltZ = parentCard.isDragging ? tiltParent.eulerAngles.z : (curveRotationOffset * (curve.rotationInfluence * parentCard.SiblingAmount()));

        tiltParent.eulerAngles = new Vector3(
            Mathf.LerpAngle(tiltParent.eulerAngles.x, tiltX + (sine * autoTiltAmount), tiltSpeed * Time.deltaTime),
            Mathf.LerpAngle(tiltParent.eulerAngles.y, tiltY + (cosine * autoTiltAmount), tiltSpeed * Time.deltaTime),
            Mathf.LerpAngle(tiltParent.eulerAngles.z, tiltZ, tiltSpeed / 2 * Time.deltaTime)
        );
    }

    private void Select(Card card, bool state)
    {
        DOTween.Kill(2, true);
        float dir = state ? 1 : 0;
        shakeParent.DOPunchPosition(shakeParent.up * selectPunchAmount * dir, scaleTransition, 10, 1);
        shakeParent.DOPunchRotation(Vector3.forward * (hoverPunchAngle / 2), hoverTransition, 20, 1).SetId(2);

        if (scaleAnimations)
        {
            transform.DOScale(scaleOnHover, scaleTransition).SetEase(scaleEase);
        }
    }

    public void Swap(float dir = 1)
    {
        if (!swapAnimations) return;

        DOTween.Kill(2, true);
        shakeParent.DOPunchRotation(Vector3.forward * swapRotationAngle * dir, swapTransition, swapVibrato, 1).SetId(3);
    }

    private void BeginDrag(Card card)
    {
        if (scaleAnimations)
        {
            transform.DOScale(scaleOnSelect, scaleTransition).SetEase(scaleEase);
        }

        // canvas.overrideSorting = true;
    }

    private void EndDrag(Card card)
    {
        canvas.overrideSorting = false;
        transform.DOScale(1, scaleTransition).SetEase(scaleEase);
    }

    private void PointerEnter(Card card)
    {
        if (scaleAnimations)
        {
            transform.DOScale(scaleOnHover, scaleTransition).SetEase(scaleEase);
        }

        DOTween.Kill(2, true);
        shakeParent.DOPunchRotation(Vector3.forward * hoverPunchAngle, hoverTransition, 20, 1).SetId(2);
    }

    private void PointerExit(Card card)
    {
        if (!parentCard.wasDragged)
        {
            transform.DOScale(1, scaleTransition).SetEase(scaleEase);
        }
    }

    private void PointerUp(Card card, bool longPress)
    {
        if (scaleAnimations)
        {
            transform.DOScale(longPress ? scaleOnHover : scaleOnSelect, scaleTransition).SetEase(scaleEase);
        }

        canvas.overrideSorting = false;
        visualShadow.localPosition = shadowDistance;
        shadowCanvas.overrideSorting = true;
    }

    private void PointerDown(Card card)
    {
        if (scaleAnimations)
        {
            transform.DOScale(scaleOnSelect, scaleTransition).SetEase(scaleEase);
        }

        visualShadow.localPosition += Vector3.down * shadowOffset;
        shadowCanvas.overrideSorting = false;
    }
}
