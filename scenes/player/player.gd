extends CharacterBody2D

class_name Player

signal player_damaged
signal player_dead

@onready var animations: AnimatedSprite2D = $Animations
@onready var audio: AudioStreamPlayer2D = $Sounds
@onready var dash_cd_label: Sprite2D = $DashCDLabel
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Player attributes
@export var initial_hp: float
@export var SPEED: float
@export var DASH_SPEED: float
var moving: bool = false
var dead: bool = false
var is_dashing: bool = false

# Dash
var last_direction: Vector2 = Vector2.ZERO
var dashed_position: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var until_dash: float = 0.0
const DASH_TIME: float = 0.4
const DASH_CD: float = 2.0

var spiral_path = []
var spiral_time_instant = 0

var external_velocity: Vector2 = Vector2.ZERO

@onready var current_hp: float = initial_hp


func _ready() -> void:
	self.player_dead.connect(on_player_death)


func on_player_death():
	dead = true
	var tween = get_tree().create_tween()
	# Fade to 0.5 alpha
	tween.tween_property(self, "modulate:a", 0, 0.3)


func take_damage(dmg_amount: float) -> float:
	if is_dashing:
		return current_hp
	current_hp = current_hp - dmg_amount
	emit_signal("player_damaged", dmg_amount)
	if !dead:
		audio.play_sound("TAKE_DMG")
	var tween = get_tree().create_tween()
	# Fade to 0.5 alpha
	tween.tween_property($Animations, "modulate:v", 1, 0.1).from(15)
	#tween.tween_property($Animations, "modulate", Color.WHITE, 0.1).from(Color.CRIMSON)

	if current_hp < 0:
		player_dead.emit()
	return current_hp


func pull(position: Vector2, pull_force: float):
	var direction = position - self.global_position
	self.external_velocity = direction * pull_force


func pull_spiral(stomp_position: Vector2, stomp_duration_in_frames: int):
	spiral_path = compute_spiral_points(self.global_position, stomp_position, stomp_duration_in_frames)
	spiral_time_instant = 0


func _physics_process(delta: float) -> void:
	if dead == true:
		return

	if spiral_path.size() > 0 and not is_dashing:
		if spiral_time_instant < spiral_path.size():
			global_position = spiral_path[spiral_time_instant]
			spiral_time_instant += 1
		else:
			spiral_path = []
			spiral_time_instant = 0
	else:
		var direction_x := Input.get_axis("ui_left", "ui_right")
		var direction_y := Input.get_axis("ui_up", "ui_down")

		if direction_x != 0 or direction_y != 0:
			last_direction.y = direction_y
			last_direction.x = direction_x

		if until_dash > 0:
			until_dash -= delta
		else:
			dash_cd_label.visible = false

		print("is_dashing ", is_dashing, " , until_dash ", until_dash)
		if Input.is_action_just_pressed("dash") and not is_dashing and (until_dash <= 0):
			is_dashing = true
			dash_timer = DASH_TIME
			velocity.y = last_direction.y * DASH_SPEED / sqrt(2)
			velocity.x = last_direction.x * DASH_SPEED / sqrt(2)
			until_dash = DASH_CD
			dash_cd_label.visible = true
			collision_mask = 4

		if is_dashing:
			dash_timer -= delta
			animations.play("dash")
			#audio.play_sound("DASH")
			moving = true

			if dash_timer <= 0:
				is_dashing = false
				velocity.x = 0
				velocity.y = 0
				collision_mask = 14

		else:
			velocity.x = 0
			velocity.y = 0

			if direction_x != 0 and direction_y == 0:
				velocity.x = direction_x * SPEED
				animations.play('walk')
				moving = true
				audio.play_sound("STEP")
			elif direction_y != 0 and direction_x == 0:
				velocity.y = direction_y * SPEED
				animations.play('walk')
				moving = true
				audio.play_sound("STEP")
			elif direction_y != 0 and direction_x != 0:
				velocity.y = direction_y * SPEED / sqrt(2)
				velocity.x = direction_x * SPEED / sqrt(2)
				animations.play('walk')
				moving = true
				audio.play_sound("STEP")
			else:
				animations.play('idle')
				if moving:
					audio.play_sound("STOP_MOVING")
					moving = false

		velocity = velocity + external_velocity

	move_and_slide()
	external_velocity = Vector2.ZERO


func compute_spiral_track_position(spiral_start_position: Vector2, spiral_end_position: Vector2, t: float) -> Vector2:
	# Calculate the direction vector from spiral_end_position to spiral_start_position
	var direction = spiral_start_position - spiral_end_position
	# The maximum radius is the distance from spiral_end_position to spiral_start_position
	var max_radius = direction.length()

	# Normalize the direction to get the unit vector
	var unit_direction = direction.normalized()

	# Calculate the initial angle (thetaB) of the start point relative to spiral_end_position
	var thetaB = atan2(direction.y, direction.x)

	# The spiral should gradually move from the start to the end. We increase the angle progressively.
	# We use an exponential function or linear function for smooth spiraling behavior.
	var theta = thetaB + t * 4 * PI # Multiply by a factor to control the number of spiral turns (4 * PI for 2 full turns)

	# Interpolate the position along the spiral path using the fixed radius and current angle
	var x = (spiral_end_position.x + max_radius * (1 - t) * cos(theta))
	var y = (spiral_end_position.y + max_radius * (1 - t) * sin(theta))

	return Vector2(x, y)


func compute_spiral_points(spiral_start_position: Vector2, spiral_end_position: Vector2, numPoints: int):
	var points = []
	var time: float = 0.
	for i in range(numPoints):
		time = float(i) / float(numPoints)
		points.append(compute_spiral_track_position(spiral_start_position, spiral_end_position, time))
	return points
