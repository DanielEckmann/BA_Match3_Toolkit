extends Piece

signal grow_obstacle(pos)

func _ready():
	self.grow_obstacle.connect(get_parent()._on_grow_obstacle)
	super._ready()

func destroy():
	pass

func set_color(color, sprite):
	pass

func take_damage(amount):
	pass

func _on_adjacent_match():
	dim()
	matched = true

func _on_turn_end():
	emit_signal("grow_obstacle", self.pos)
