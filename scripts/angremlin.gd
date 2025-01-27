extends CharacterBody2D

const MAX_SPEED = 200
const ACCEL = 1500
const FRICTION = 1200

var animation_player: AnimationPlayer
var is_chasing = false

func _ready():
	
	animation_player = $AnimationPlayer

func _process(delta):
	pass

func character_movement():
	
	move_and_slide()
