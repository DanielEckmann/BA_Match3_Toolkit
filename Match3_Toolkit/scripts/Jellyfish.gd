extends Piece

signal jellyfish_destroyed()

func _ready():
	self.jellyfish_destroyed.connect(get_node("/root/game_window/GoalCounter")._on_jellyfish_destroyed)
	super._ready()

func destroy():
	emit_signal("jellyfish_destroyed")
	super.destroy()
