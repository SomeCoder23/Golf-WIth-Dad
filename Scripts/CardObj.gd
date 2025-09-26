class_name CardObj

var value: int
var real_value : String
var sprite: Texture2D

func _init(_value: int, _sprite: Texture2D, _real_value : String):
	value = _value
	sprite = _sprite
	real_value = _real_value
