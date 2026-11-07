extends CharacterBody2D

@export var move_speed: float = 150.0
@export var animation_fps: float = 8.0
@export var dash_speed: float = 500.0
@export var melee_damage: int = 15


var dash_direction: Vector2 = Vector2.ZERO
var animation_timer: float = 0.0

@onready var visuals: Sprite2D = $Visuals
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var muzzle: Marker2D = $WeaponPivot/GunVisual/Muzzle
@onready var fire_cooldown: Timer = $FireCooldown
@onready var dash_duration: Timer = $DashDuration
@onready var dash_cooldown: Timer = $DashCooldown
@onready var melee_hitbox: Area2D = $WeaponPivot/MeleeHitbox
@onready var melee_duration: Timer = $MeleeDuration
@onready var gun_visual: Sprite2D = $WeaponPivot/GunVisual
@onready var surge_hitbox: Area2D = $SurgeHitbox

const NORTH_TEXTURE: Texture2D = preload("res://src/assets/placeholders/player/2_north.png") # all textures for PC
const SOUTH_TEXTURE: Texture2D = preload("res://src/assets/placeholders/player/2_south.png")
const SIDE_TEXTURE: Texture2D = preload("res://src/assets/placeholders/player/2_side.png")
const DIAG_UP_TEXTURE: Texture2D = preload("res://src/assets/placeholders/player/2_diagup.png")
const DIAG_DOWN_TEXTURE: Texture2D = preload("res://src/assets/placeholders/player/2_diagdown.png")
const CROSSHAIR_TEXTURE: Texture2D = preload("res://src/assets/placeholders/HUD/1crosshair.png")

const BULLET_SCENE: PackedScene = preload("res://src/entities/player/projectiles/player_bullet.tscn")

func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("dash") \
		and dash_cooldown.is_stopped() \
		and dash_duration.is_stopped() \
		and input_direction != Vector2.ZERO:
		dash_direction = input_direction.normalized()
		dash_duration.start()
		dash_cooldown.start() 

	if not dash_duration.is_stopped():
		velocity = dash_direction * dash_speed
	else:
		velocity = input_direction * move_speed


	var aim_direction = get_global_mouse_position() - global_position # calcuate mouse direction relative to player
	var facing_angle = snappedf(aim_direction.angle(), PI / 4.0)
	var facing_direction = Vector2.from_angle(facing_angle).round()

	if facing_direction.x < 0 and facing_direction.y < 0: # set the texture based on input
		visuals.texture = DIAG_UP_TEXTURE
		visuals.flip_h = true
	elif facing_direction.x > 0 and facing_direction.y < 0:
		visuals.texture = DIAG_UP_TEXTURE
		visuals.flip_h = false
	elif facing_direction.x < 0 and facing_direction.y > 0:
		visuals.texture = DIAG_DOWN_TEXTURE
		visuals.flip_h = true
	elif facing_direction.x > 0 and facing_direction.y > 0:
		visuals.texture = DIAG_DOWN_TEXTURE
		visuals.flip_h = false
	elif facing_direction.x < 0:
		visuals.texture = SIDE_TEXTURE
		visuals.flip_h = true
	elif facing_direction.x > 0:
		visuals.texture = SIDE_TEXTURE
		visuals.flip_h = false
	elif facing_direction.y < 0:
		visuals.texture = NORTH_TEXTURE
		visuals.flip_h = false
	elif facing_direction.y > 0:
		visuals.texture = SOUTH_TEXTURE
		visuals.flip_h = false

	if input_direction != Vector2.ZERO: # if the player is moving
		animation_timer += delta # update the animation timer
		while animation_timer >= 1.0 / animation_fps: # update the frame based on timer
			animation_timer -= 1.0 / animation_fps
			visuals.frame = (visuals.frame + 1) % 4
	else:
		animation_timer = 0.0
		visuals.frame = 0
	

	move_and_slide()

	weapon_pivot.look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("melee"):
		melee_attack()

	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("temporal_surge"):
		temporal_surge()


func _ready() -> void:
	Input.set_custom_mouse_cursor(
		CROSSHAIR_TEXTURE,
		Input.CURSOR_ARROW,
		Vector2(10, 10)
	)

func shoot() -> void:
	if not fire_cooldown.is_stopped():
		return
	if not melee_duration.is_stopped():
		return
	var bullet = BULLET_SCENE.instantiate() # creates copy of bullet scene
	get_tree().current_scene.add_child(bullet) # adds to scene
	bullet.global_position = muzzle.global_position # set the bullet's starting position to the muzzle's position
	bullet.direction = Vector2.RIGHT.rotated(weapon_pivot.global_rotation) # set the bullet's direction based on the weapon's rotation
	
	fire_cooldown.start()

func melee_attack() -> void:
	if not melee_duration.is_stopped():
		return

	gun_visual.hide()
	melee_duration.start()
	for body in melee_hitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(melee_damage)

func _on_melee_duration_timeout() -> void:
	gun_visual.show()

func temporal_surge() -> void:
	for body in surge_hitbox.get_overlapping_bodies():
		if body is RigidBody2D:
			var push_direction = global_position.direction_to(body.global_position)
			body.apply_central_impulse(push_direction * 160.0)
