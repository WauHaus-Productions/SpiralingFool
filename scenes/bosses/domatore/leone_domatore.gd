extends BossBase
class_name LeoneDomatore

signal state_changed

@export_group("Timers")
@export var pursuit_time : float = 3.0
@export var attack_charge_time : float = 1.0
@export var recharge_time : float = 2.0

@export_group("Attack parameters")
@export var attack_speed : float = 150.0

@onready var animator : AnimatedSprite2D = $Animations
@onready var timer : Timer = $Timer

enum StateEnum {IDLE, PURSUIT, CHARGE, ATTACK}
var state : StateEnum = StateEnum.IDLE

var attack_direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	super()
	
	# Connect timer to change states
	timer.timeout.connect(change_state)
	
	# Connect animator with state change
	state_changed.connect(switch_animation)
	animator.animation_finished.connect(on_animation_finished)
	
	# Start in IDLE state and start transition to PURSUIT state
	state = StateEnum.IDLE
	timer.start(recharge_time)

func _physics_process(delta: float) -> void:
	if (state == StateEnum.PURSUIT):
		# Move towards player
		var dir_to_player : Vector2 = player.global_position - global_position
		dir_to_player = dir_to_player.normalized()
		move_to(dir_to_player, speed)
	elif (state == StateEnum.ATTACK):
		# Jump towards player
		move_to(attack_direction, attack_speed)

func move_to(direction: Vector2, move_speed: float) -> void:
	# Flip animation based on movement
	animator.flip_h = direction.x < 0
	
	# Move and collide
	velocity = direction * move_speed
	move_and_slide()

func switch_animation() -> void:
	if (state == StateEnum.IDLE):
		animator.play("idle")
	elif (state == StateEnum.PURSUIT):
		animator.play("run_start")
	elif (state == StateEnum.CHARGE):
		animator.play("attack_charge_start")
	elif (state == StateEnum.ATTACK):
		animator.play("attack_jump")

func on_animation_finished():
	# Launch the loop of the run and attack_charge animations
	if (state == StateEnum.PURSUIT):
		animator.play("run_loop")
	elif (state == StateEnum.CHARGE):
		animator.play("attack_charge_loop")
	# Change the state after the attack has executed
	elif (state == StateEnum.ATTACK):
		change_state()

func change_state() -> void:
	if (state == StateEnum.IDLE):
		# Start pursuiting the player for {pursuit_time} seconds
		state = StateEnum.PURSUIT
		timer.start(pursuit_time)
	elif (state == StateEnum.PURSUIT):
		# Start charging the attack for {attack_charge_time} seconds
		state = StateEnum.CHARGE
		timer.start(attack_charge_time)
	elif (state == StateEnum.CHARGE):
		# Launch the attack by defining the attack direction
		state = StateEnum.ATTACK
		attack_direction = (player.global_position - global_position).normalized()
		
	elif (state == StateEnum.ATTACK):
		# Return idle after the attack
		state = StateEnum.IDLE
		timer.start(recharge_time)
	
	state_changed.emit()
