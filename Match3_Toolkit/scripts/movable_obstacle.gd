extends Piece

func destroy():
	pass

func set_color(color, sprite):
	pass

func take_damage(amount):
	pass

func _on_adjacent_match():
	dim()
	matched = true
