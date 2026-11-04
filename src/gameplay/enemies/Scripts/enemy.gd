extends CharacterBody2D

#onready var player = get_node()   # if you rather use the scene just say preload("player scene")
@export var health := 100
var dir := Vector2.ZERO
@export var speed = 50
@export var move_time := 2.0
@export var idle_time := 1.5
var rdir

var current_states
enum enemy_states {MOVERIGHT, MOVELEFT, MOVEUP, MOVEDOWN, IDLE}

func _ready() -> void:
	health = 100
	random_generation()

func _physics_process(delta: float) -> void:
	$Health.value = health

	match current_states:
		enemy_states.MOVERIGHT:
			dir = Vector2.RIGHT
		enemy_states.MOVELEFT:
			dir = Vector2.LEFT
		enemy_states.MOVEUP:
			dir = Vector2.UP
		enemy_states.MOVEDOWN:
			dir = Vector2.DOWN
		enemy_states.IDLE:
			dir = Vector2.ZERO

	if $Alert.value == $Alert.max_value:
		#dir = (player.position - position).normalized()
		pass

	# turn the vision cone to face where we're heading
	if dir != Vector2.ZERO:
		$Area2D.rotation = dir.angle() - PI / 2

	velocity = dir * speed
	move_and_slide()


func random_generation():
	rdir = randi() % 4
	random_direction()
	$MoveTimer.start(move_time)

func start_idle():
	current_states = enemy_states.IDLE
	$MoveTimer.start(idle_time)

func random_direction():
	match rdir:
		0:
			current_states = enemy_states.MOVERIGHT
		1:
			current_states = enemy_states.MOVELEFT
		2:
			current_states = enemy_states.MOVEUP
		3:
			current_states = enemy_states.MOVEDOWN

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$AlerTimer.start()

func _on_timer_timeout() -> void:
	$Alert.value += 10

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$AlerTimer.stop()


func _on_move_timer_timeout() -> void:
	if current_states == enemy_states.IDLE:
		random_generation()   
	else:
		start_idle()             
