extends CharacterBody2D

const MAX_SPEED = 200
const ACCEL = 1500
const FRICTION = 1200

var animation_player: AnimationPlayer
var is_chasing = false
@export var speed: float = 100
var player = null # reference the player
var direction = null # instantiate

func _ready():
	
	animation_player = $AnimationPlayer
	$Area2D.connect("body_entered", _on_area_entered)
	$Area2D.connect("body_exited", _on_area_exited)


func _physics_process(delta):
	
	character_movement(delta)


func character_movement(delta):
	
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_chasing = true
		player = body

func _on_area_exited(body: Node2D) -> void:
	if body == player:
		is_chasing = false
		player = null
