extends AudioStreamPlayer2D

@export var cardSfx = []
@export var cardFlipSfx = []

func play_cardSfx():
	_play_Sfx(cardSfx)

func play_cardFlip():
	_play_Sfx(cardFlipSfx)
	
func _play_Sfx(sounds):
	if sounds.is_empty():
		return
	var ranIndex = randi_range(0, sounds.size() - 1)
	stream = sounds[ranIndex]
	play()
