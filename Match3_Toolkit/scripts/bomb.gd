extends Piece

enum types {HORIZONTAL, VERTICAL, COLOR, RADIUS}

signal bomb_destroyed(pos, type, color)

var type = types.HORIZONTAL
var exploded = false

func _ready():
	self.bomb_destroyed.connect(get_parent()._on_bomb_destroyed)
	super._ready()

func destroy():
	if exploded:
		return
	exploded = true
	emit_signal("bomb_destroyed", self.pos, self.type, self.color)
	super.destroy()

func set_type(t):
	type = t
