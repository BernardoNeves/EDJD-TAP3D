using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System.Linq;

public class CardHolder : MonoBehaviour
{
    [SerializeField] private Card selectedCard;
    [SerializeReference] private Card hoveredCard;
    public bool instantiateMaterial = true;

    [SerializeField] private GameObject slotPrefab;
    private RectTransform rect;

    [Header("Spawn Settings")]
    [SerializeField] private int cardsToSpawn = 7;
    public List<Card> cards;

    private bool isCrossing = false;
    [SerializeField] private bool tweenCardReturn = true;

    [SerializeField] private Material[] materials;

    private void Start()
    {
        InitializeSlots();
        InitializeCards();
        rect = GetComponent<RectTransform>();
        StartCoroutine(UpdateCardVisualIndices());
    }

    private void InitializeSlots()
    {
        for (int i = 0; i < cardsToSpawn; i++)
        {
            Instantiate(slotPrefab, transform);
        }
    }

    private void InitializeCards()
    {
        cards = GetComponentsInChildren<Card>().ToList();
        for (int i = 0; i < cards.Count; i++)
        {
            Card card = cards[i];
            card.PointerEnterEvent.AddListener(CardPointerEnter);
            card.PointerExitEvent.AddListener(CardPointerExit);
            card.BeginDragEvent.AddListener(BeginDrag);
            card.EndDragEvent.AddListener(EndDrag);
            card.name = i.ToString();
            if (materials.Length > 0)
            {
                card.material = materials[i % materials.Length];
                card.cardVisual?.Initialize(card, i, card.material);
            }
        }
    }

    private IEnumerator UpdateCardVisualIndices()
    {
        yield return new WaitForSecondsRealtime(0.1f);
        foreach (Card card in cards)
        {
            card.cardVisual?.UpdateIndex(transform.childCount);
        }
    }

    private void BeginDrag(Card card)
    {
        selectedCard = card;
    }

    private void EndDrag(Card card)
    {
        if (selectedCard == null) return;

        Vector3 targetPosition = selectedCard.selected ? new Vector3(0, selectedCard.selectionOffset, 0) : Vector3.zero;
        selectedCard.transform.DOLocalMove(targetPosition, tweenCardReturn ? 0.15f : 0).SetEase(Ease.OutBack);

        AdjustRectSizeDelta();

        selectedCard = null;
    }

    private void AdjustRectSizeDelta()
    {
        rect.sizeDelta += Vector2.right;
        rect.sizeDelta -= Vector2.right;
    }

    private void CardPointerEnter(Card card)
    {
        hoveredCard = card;
    }

    private void CardPointerExit(Card card)
    {
        hoveredCard = null;
    }

    private void Update()
    {
        HandleCardDeletion();
        DeselectAllCardsOnRightClick();

        if (selectedCard == null || isCrossing) return;

        for (int i = 0; i < cards.Count; i++)
        {
            Card currentCard = cards[i];
            if (IsCardPositionChanged(currentCard))
            {
                SwapCards(i);
                break;
            }
        }
    }

    private void HandleCardDeletion()
    {
        if (Input.GetKeyDown(KeyCode.Delete) && hoveredCard != null)
        {
            Destroy(hoveredCard.transform.parent.gameObject);
            cards.Remove(hoveredCard);
        }
    }

    private void DeselectAllCardsOnRightClick()
    {
        if (Input.GetMouseButtonDown(1))
        {
            foreach (Card card in cards)
            {
                card.Deselect();
            }
        }
    }

    private bool IsCardPositionChanged(Card card)
    {
        return (selectedCard.transform.position.x > card.transform.position.x && selectedCard.ParentIndex() < card.ParentIndex()) ||
               (selectedCard.transform.position.x < card.transform.position.x && selectedCard.ParentIndex() > card.ParentIndex());
    }

    private void SwapCards(int index)
    {
        isCrossing = true;

        Transform focusedParent = selectedCard.transform.parent;
        Transform crossedParent = cards[index].transform.parent;

        cards[index].transform.SetParent(focusedParent);
        cards[index].transform.localPosition = cards[index].selected ? new Vector3(0, cards[index].selectionOffset, 0) : Vector3.zero;
        selectedCard.transform.SetParent(crossedParent);

        isCrossing = false;

        if (cards[index].cardVisual != null)
        {
            bool swapIsRight = cards[index].ParentIndex() > selectedCard.ParentIndex();
            cards[index].cardVisual.Swap(swapIsRight ? -1 : 1);
            UpdateVisualIndices();
        }
    }

    private void UpdateVisualIndices()
    {
        foreach (Card card in cards)
        {
            card.cardVisual?.UpdateIndex(transform.childCount);
        }
    }
}
