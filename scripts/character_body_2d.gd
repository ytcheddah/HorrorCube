extends CharacterBody2D

const max_speed = 200
const accel = 1500
const friction = 1200

var trap_01: PackedScene = preload("res://scenes/Traps/trap_01.tscn")

var input = Vector2.ZERO
var animation_player : AnimationPlayer
var last_direction : String = ""  # Tracks the last direction the character was walking
var key_states = {}
var facing = Vector2(0,1) # Down by default

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
		if Input.is_action_pressed(key):
			key_states[key] = true
		elif Input.is_action_just_released(key):
			key_states[key] = false
			
		if event.is_action_pressed("Place Trap"):
			spawn_trap()
			
func print_key_states():
	
	for key in key_states.keys():
		print(key, ": ", key_states[key])
		

func get_input():
	input.x = int(Input.is_action_pressed("Move Right")) - int(Input.is_action_pressed("Move Left"))
	input.y = int(Input.is_action_pressed("Move Down")) - int(Input.is_action_pressed("Move Up"))
	# input = Input.is_action_pressed("Place Trap")
	
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
				var facing = Vector2(1,0)
			else:
				animation_player.play("walkLeft")
				last_direction = "walkLeft"
				var facing = Vector2(-1,0)
		else:  # Moving up or down
			if input.y > 0:
				animation_player.play("walkDown")
				last_direction = "walkDown"
				var facing = Vector2(0,1)
			else:
				animation_player.play("walkUp")
				last_direction = "walkUp"
				var facing = Vector2(0,-1)
				
func spawn_trap():
	# create instance of trap
	var trap_instance = trap_01.instantiate()
	
	# Position trap in front of character
	var offset = Vector2(50 * facing.x, 50 * facing.y)
	trap_instance.position = global_position + offset
	
	# Add the trap to the scene tree
	get_parent().add_child(trap_instance)
