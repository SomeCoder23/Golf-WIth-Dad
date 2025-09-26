extends Node

@export var playerIndex : int
@export var scoreLabel : Label
@export var scoreTag : String
var mySide := true
var cards_flipped := 0
var slots := []
var deckPos
var initialized := false
var score := 0
signal initialized_cards
signal game_over

func _ready() -> void:
	deckPos = $"../../CardPile/DeckPile".global_position
	slots = get_children()
	scoreLabel.set_text(scoreTag + "0")
	var real_slots = []
	for slot in slots:
		real_slots.append(slot.get_node("Sprite"))
		slot.get_node("Sprite").switch_card.connect($"../../CardPile".switch_cards)
	slots = real_slots
		
func initialize_cards(cards : Array, cardBack, mine : bool, deckCard):
	mySide = mine
	var index = 0
	var cardSlot
	var startPos = deckCard.position
	while index < slots.size() and index < cards.size():
		cardSlot = slots[index]
		var tween = create_tween()
		SoundManager.play_cardSfx()
		tween.tween_property(deckCard, "position", cardSlot.global_position, 0.35)
		await tween.finished
		cardSlot.self_modulate = Color(1, 1, 1, 1)
		cardSlot.set_card(cards[index])
		cardSlot.set_texture(cardBack)
		deckCard.position = startPos
		#print("CARD AT INDEX " + str(index) + " V: " + str(cards[index].value) + " RV: " + str(cards[index].real_value))
		index +=  1

func can_flip() -> bool:
	if mySide and !initialized:
		if cards_flipped + 1 == 2:
			initialized = true
			emit_signal("initialized_cards")
		return true
	else:
		return false
		
func flip2random():
	var cardsToFlip = slots.duplicate()
	var index = randi_range(0, cardsToFlip.size() - 1)
	cardsToFlip[index].flip_card()
	cardsToFlip.remove_at(index)
	index = randi_range(0, cardsToFlip.size() - 1)
	cardsToFlip[index].flip_card()

func flippedCard(slot, addPoints := true):
	cards_flipped += 1
	print("Flipped cards = " + str(cards_flipped))
	if addPoints:
		SoundManager.play_cardFlip()
		_calculate_points(_get_pair_slot(slot), slot.get_card())
		scoreLabel.set_text(scoreTag + str(score))
		ScoreManager.update_score(score, playerIndex)
	if cards_flipped == 6:
		print("Someone finished!!")
		emit_signal("game_over")

func flip_all_hand():
	var index = 0
	while cards_flipped != 6 and index <= 5:
		if !slots[index].isFlipped():
			slots[index].flip_card()
		index += 1
		
#get opposite slot
func _get_pair_slot(slot):
	var sIndex = slots.find(slot)
	#print("SLOT INDEX = " + str(sIndex))
	#print("SLOTS SIZE = " + str(slots.size()))
	if sIndex > -1 and sIndex < 3:
		return slots[sIndex + 3]
	else:
		return slots[sIndex - 3]		
		
func _calculate_points(pairSlot, flippedCard):
	if pairSlot.isFlipped() and pairSlot.get_card().real_value == flippedCard.real_value:
		if flippedCard.value != -2:
			score -= flippedCard.value
		else:
			score += -2
		return 40
	else:
		score += flippedCard.value
		#return -flippedCard.value
		return 0
		
#may need some work + optimization
func recalculate_points(newCard : CardObj, slot, getWeight := false):
	var oldCard = slot.get_card()
	var pairSlot = _get_pair_slot(slot)
	var pairCard = pairSlot.get_card()
	var weight := 0
	var initialScore = score
	#take away cards value from points if that slot's card was already flipped and was different from its pair
	#if old card was the same as opposite (column points = 0) add the cards value to score
	if slot.isFlipped():
		if pairSlot.isFlipped() and oldCard.value != -2 and pairCard.real_value == oldCard.real_value:
			score += pairCard.value
			weight = -50
		else:
			score -= oldCard.value
	#check is opposite card has same real value if so take away value from score so that the columns points = 0
	weight += _calculate_points(pairSlot, newCard)
	if !getWeight:
		slot.set_card(newCard, true)
		scoreLabel.set_text(scoreTag + str(score))
		ScoreManager.update_score(score, playerIndex)
		return 0
	else:
		if !slot.isFlipped():
			if !pairSlot.isFlipped():
				weight += 30 #if no card is flipped in this column yet
			elif cards_flipped == 5 and score < ScoreManager.get_score(0):
				weight += 10 + (score - ScoreManager.get_score(0)) #if this is the last remaining slot to be flipped and the computers score is better than the player's
		
		#if the new card is the same as the old card if that card is already flipped
		elif slot.isFlipped() and newCard.real_value == oldCard.real_value:
			weight -= 50
					
		weight -= (score - initialScore)
		var move = {
			"index": 1,
			"slot": slot,
			"weight": weight,
			"newScore": score
		}
		score = initialScore
		return move

func needs_card(card) -> bool:
	var initialScore = score
	var index = 0
	var usefulCard = false
	while index < 3 and !usefulCard:
		var columnMatched = _calculate_points(_get_pair_slot(slots[index]), slots[index].get_card())
		if !columnMatched: #if the column is not already matched
			var pairMatch = _calculate_points(_get_pair_slot(slots[index]), card)
			var slotMatch = _calculate_points(slots[index], card)
			if pairMatch > 0 or slotMatch > 0:
				usefulCard = true
		index += 1
	score = initialScore
	return usefulCard
	
func set_score(newScore):
	ScoreManager.update_score(newScore, playerIndex)
	score = newScore
	scoreLabel.set_text(scoreTag + str(score))
	
