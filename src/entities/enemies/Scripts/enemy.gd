extends CharacterBody2D
# ok so the patrol points is easy to set up, 
#you just have to add a patrol points node as a node 2d and as many markers 2d as you want
# and asing it in the inspector in the level scene

var player = null
var patrol_points: Array[Marker2D] = []
var current_point_index : int = 0
var dir : Vector2 = Vector2.ZERO
var facing_direction : Vector2 = Vector2.RIGHT
var In_Vision : bool = false
var player_pos : Vector2 = Vector2.ZERO
var search_rotation : float = 0.0
var search_direction : float = 1.0

@export var speed : float = 300.0
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 7.0
@export var patrol_points_parent : Node2D 

enum EnemyState {
	PATROL,
	WAITING,
	CHASE,
	ALERT,
	INVESTIGATE
}
var current_state : EnemyState = EnemyState.PATROL

func _ready() -> void:  # poopulates the marker 2D's
	player = get_tree().get_first_node_in_group("player") as Node2D
	for i in range(patrol_points_parent.get_child_count()):
		patrol_points.append(patrol_points_parent.get_child(i) as Marker2D)


func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		print("enter")
		In_Vision = true
		player_pos = body.global_position
		
		if current_state == EnemyState.PATROL or current_state == EnemyState.WAITING:
			$Alert.value = 0
			$AlertTimer.start()
			current_state = EnemyState.ALERT
	
		if current_state == EnemyState.CHASE:
			$GoBackTimer.stop()
			
		if current_state == EnemyState.INVESTIGATE:
			current_state = EnemyState.CHASE


func _on_vision_area_body_exited(body: Node2D) -> void:
	if body == player:
		print("exit")
		In_Vision = false
		
		if current_state == EnemyState.CHASE:
			$GoBackTimer.start()
		if current_state == EnemyState.ALERT:
			$AlertTimer.stop()
			$Alert.value = 0
			player_pos = player.global_position
			current_state = EnemyState.PATROL


func _physics_process(delta: float) -> void:
	match current_state:
		EnemyState.PATROL:
			patrol()
		EnemyState.WAITING:
			waiting()
		EnemyState.CHASE:
			chase()
		EnemyState.ALERT:
			alert()
		EnemyState.INVESTIGATE:
			investigate(delta)
	move_and_slide()
	$VisionArea.rotation = facing_direction.angle()


func _on_patrol_timer_timeout() -> void:
	if current_state == EnemyState.WAITING:
		current_point_index += 1
		current_state = EnemyState.PATROL
	
		if current_point_index > patrol_points.size() - 1:  # also works :current_point_index = (current_point_index + 1) % patrol_points.size()
			current_point_index = 0    # resets to array 0


func patrol():
	dir = patrol_points[current_point_index].global_position - global_position
	if dir.length() < 5:
		current_state = EnemyState.WAITING
		$PatrolTimer.wait_time = randf_range(min_wait_time, max_wait_time)
		$PatrolTimer.start()
	else:
		velocity = dir.normalized() * speed
		facing_direction = dir.normalized()


func waiting():
	dir = Vector2.ZERO
	velocity = Vector2.ZERO

func alert():
	dir = Vector2.ZERO
	velocity = Vector2.ZERO
	if In_Vision:
		facing_direction = (player.global_position - global_position).normalized()
		player_pos = player.global_position
		$Alert.value = $Alert.max_value * (1.0 - $AlertTimer.time_left / $AlertTimer.wait_time)
	else:
		facing_direction = (player_pos - global_position).normalized()



func chase():
	if In_Vision:
		player_pos = player.global_position
		dir = (player_pos - global_position).normalized()
		facing_direction = dir
		velocity = dir * speed
	else:
		if global_position.distance_to(player_pos) > 5:
			dir = (player_pos - global_position).normalized()
			facing_direction = dir
			velocity = dir * speed
		else:
			velocity = Vector2.ZERO


func investigate(delta):
	velocity = Vector2.ZERO
	
	search_rotation += 2.0 * delta
	facing_direction = Vector2.RIGHT.rotated(search_rotation)
	$Alert.value = $Alert.min_value * (1.0 - $AlertTimer.time_left / $AlertTimer.wait_time)


func _on_alert_timer_timeout() -> void:
	if current_state == EnemyState.ALERT and In_Vision:
		current_state = EnemyState.CHASE


func _on_go_back_timer_timeout() -> void:
	if current_state == EnemyState.CHASE:
		current_state = EnemyState.INVESTIGATE
		$GoBackTimer.start()

	elif current_state == EnemyState.INVESTIGATE:
		current_state = EnemyState.PATROL
