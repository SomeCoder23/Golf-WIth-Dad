extends TextureRect

var _card : CardObj
var flipped := false
var hand
signal switch_card(card)

func _ready() -> void:
	hand = get_parent().get_parent()
	
func _on_slot_clicked(event : InputEvent):
	if event is InputEventMouseButton and event.pressed and event.get_button_index() == MOUSE_BUTTON_LEFT:
		_is_valid_flip()
	
func _is_valid_flip():
	if GameStuff.state == GameStuff.GameState.CHOOSING_SLOT:
		emit_signal("switch_card", self)
	elif hand.can_flip():
		flip_card()
			
func set_card(card : CardObj, update := false):
	_card = card
	if update:
		set_texture(_card.sprite)
	
func flip_card(addPoints := true):
	if flipped:
		return
	set_texture(_card.sprite)
	flipped = true
	hand.flippedCard(self, addPoints)

func isFlipped() -> bool:
	return flipped
	
func get_card() -> CardObj:
	return _card
