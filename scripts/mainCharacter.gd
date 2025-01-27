extends CharacterBody2D

const max_speed = 200
const accel = 1500
const friction = 1200

@onready var headlight: Node2D = $coneLight
var trap_01: PackedScene = preload("res://scenes/Traps/trap_01.tscn")
var animation_player : AnimationPlayer

var headlight_is_on = false

var input = Vector2.ZERO
var last_direction : String = ""  # Tracks the last direction the character was walking
var key_states = {}
var facing = Vector2(0,1) # Down by default
var trap_list = []
var can_spawn_trap = true
var trap_cooldown_time = 1 

func _ready():
	# Make sure we have an AnimationPlayer node in the scene
	animation_player = $AnimationPlayer  # Assuming your AnimationPlayer is a direct child of this node
	# Initialize Keys We'd like to track
	key_states = {
		"Move Up": false,
		"Move Down": false,
		"Move Right": false,
		"Move Left": false,
		"Place Trap": false,
	}

func _process(delta):
	player_movement(delta)
	update_animation()
	# print_key_states()

func _input(event):
	# Check if the event was a keypress or a key release
	for key in key_states.keys():
		if Input.is_action_just_pressed(key):
			key_states[key] = true
		elif Input.is_action_just_released(key):
			key_states[key] = false
			
	if event.is_action_pressed("Place Trap") and event.is_pressed():	
		spawn_trap()
		
	if event.is_action_pressed("Toggle HeadLight") and event.is_pressed():
		toggle_headlight()		
			
func print_key_states():
	
	for key in key_states.keys():
		print(key, ": ", key_states[key])
		

func get_input():
	input.x = int(Input.is_action_pressed("Move Right")) - int(Input.is_action_pressed("Move Left"))
	input.y = int(Input.is_action_pressed("Move Down")) - int(Input.is_action_pressed("Move Up"))
	
	return input.normalized()

func player_movement(delta):
	input = get_input()

	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)

	#print(input) # shows how the movement works, really cool!
	move_and_slide()

func update_animation():
	if input == Vector2.ZERO:
		if last_direction != "":
			# When the character stops, play the first frame of the last walking animation
			animation_player.play(last_direction + "_idle")
		else:
			# If there's no last direction, do nothing or play a default idle (optional)
			pass
	else:
		# Determine movement direction and play the corresponding animation
		if abs(input.x) > abs(input.y):  # Moving left or right
			if input.x > 0:
				animation_player.play("walkRight")
				last_direction = "walkRight"
				facing = Vector2(1,0)
			else:
				animation_player.play("walkLeft")
				last_direction = "walkLeft"
				facing = Vector2(-1,0)
		else:  # Moving up or down
			if input.y > 0:
				animation_player.play("walkDown")
				last_direction = "walkDown"
				facing = Vector2(0,1)
			else:
				animation_player.play("walkUp")
				last_direction = "walkUp"
				facing = Vector2(0,-1)
				
func spawn_trap():
	# create trap instance
	var trap_instance = trap_01.instantiate()
	trap_list.append(trap_instance)
	
	# Position trap in front of character
	# the -105 and -90 need to be fixed in the future
	var offset = Vector2((60 * facing.x) - 105, (60 * facing.y) - 90) 
	trap_instance.position = global_position + offset
	
	get_parent().add_child(trap_instance)
	
	# Start cooldown after each placed trap
	can_spawn_trap = false
	await((get_tree().create_timer(trap_cooldown_time)).timeout)
	can_spawn_trap = true
	
	# print for debugging
	print("Trap # ",len(trap_list), ": ",trap_instance.position)
	print(facing)
	
func toggle_headlight():
	# if its on, this will hide it, otherwise it will show. defaults to false
	if headlight_is_on:
		headlight_is_on = false
		headlight.hide()
	else:
		headlight_is_on = true
		headlight.show()
