extends Node2D

# Basis of Code taken from https://www.youtube.com/watch?v=YhykrMFHOV4&list=PL4vbr3u7UKWqwQlvwvgNcgDL1p_3hcNn2

class_name Piece

enum colors {YELLOW, PINK, ORANGE, LIGHT_GREEN, GREEN, BLUE, NONE}

@export var color: colors
@export var sprite: CompressedTexture2D
@export var health: int
@export var movable: bool

var move_tween
var matched = false
var match_magnitude = 0
var moved = false
var pos
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_attributes(color, sprite, health):
	self.color = color
	self.sprite = sprite
	self.health = health
	
	var s = get_node("Sprite2D")
	s.set_texture(sprite)

func set_color(color, sprite):
	self.color = color
	self.sprite = sprite
	
	var s = get_node("Sprite2D")
	s.set_texture(sprite)

func move(target):
	move_tween = self.create_tween()
	move_tween.tween_property(self, "position", target, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	move_tween.play()
	pos = target
	moved = true

func set_match_magnitude(mag):
	if mag > self.match_magnitude:
		self.match_magnitude = mag

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func take_damage(amount):
	health -= amount
	if health <= 0:
		destroy()
	match_magnitude = 0

func destroy():
	dim()
	matched = true

func dim():
	var sprite = get_node("Sprite2D")
	sprite.modulate = Color(1, 1, 1, 0.5)
