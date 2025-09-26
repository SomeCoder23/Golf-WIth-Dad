extends Node

signal chose_pile()

func _on_pile_clicked(event : InputEvent):
	if event is InputEventMouseButton and event.pressed and event.get_button_index() == MOUSE_BUTTON_LEFT:
		print(get_name(), " slot clicked")
		if GameStuff.state == GameStuff.GameState.PLAYER_TURN:
			emit_signal("chose_pile")
		
