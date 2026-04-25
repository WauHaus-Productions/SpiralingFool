extends BossBase

# timers
@onready var stomp_cooldown_timer: Timer =  $StompTimer # timer che decide tra quanto parte il colpo una volta visto il player
@onready var can_stomp_again_timer: Timer =  $StompDurationTimer # timer che ti dice se puoi già far partire un altro stomp
@onready var vision_area: Area2D = $VisionArea
@onready var audio_player: WAUAudioPlayer = $Sounds

@onready var stomp_attack: StompAttack = $StompAttack

@export var target: Node2D = null :
	set(value):
		target = value

var vision_player: Player = null
var is_stomping: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	stomp_cooldown_timer.timeout.connect(on_stomp_timer_end)
	vision_area.body_entered.connect(on_player_in_range)
	vision_area.body_exited.connect(on_player_out_of_range)
	animations.animation_finished.connect(_on_animations_animation_finished)
	# stomp_cooldown_timer.start()

func on_player_in_range(body: Node2D):
	if body.is_in_group("Player"):
		vision_player = body as Player
		print("Player in range")
		start_or_continue_stomp_timer()

# FABIO: HO IL DUBBIO CHE NON SERVA A NULLA
func on_player_out_of_range(body: Node2D):
	if body.is_in_group("Player"):
		print("Player out of range")
		vision_player =  null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if target != null:
		if !is_stomping:
			move_towards(delta, target)
	if vision_player != null:
		start_or_continue_stomp_timer()

func start_or_continue_stomp_timer():
	if stomp_cooldown_timer.is_stopped():
		if can_stomp_again_timer.is_stopped():
			start_stomp_timer()
	else:
		pass

func start_stomp_timer():
	stomp_cooldown_timer.start()
	
func move_towards(_delta, curr_target: Node2D):
	if curr_target != null:
		var direction : Vector2 = (curr_target.global_position - self.global_position).normalized()
		self.velocity = direction*self.speed
		self.move_and_slide()
		animate_movement(direction)

	else:
		self.idle()

func on_stomp_timer_end():
	# time to stomp, move it to the correct position
	is_stomping = true
	#can_stomp_again_timer.timeout.connect(on_can_stomp_again_timer)
	can_stomp_again_timer.start()
	
	if self.velocity.x > 0: 
		# move right and animate right
		stomp_attack.position = $StompRightPosition.position
		stomp_right()
	else:
		stomp_attack.position = $StompLeftPosition.position
		stomp_left()
	stomp_attack.run()
	
	
#func on_can_stomp_again_timer_end():
	#pass

func animate_movement(direction: Vector2):
	if direction.x > 0:
		self.walk_right()
	else:
		self.walk_left()


func stomp_left():
	animate("stomp_left")
	audio_player.play_sound("charge_attack")

func stomp_right():
	animate("stomp_right")
	audio_player.play_sound("charge_attack")


func _on_animations_animation_finished() -> void:
	if is_stomping == true and (animations.animation == "stomp_right" or animations.animation == "stomp_left"):
		audio_player.play_sound("slam_attack")
		print("Stomp finished ", animations.animation)
		is_stomping=false
		stomp_attack.pull_player()
		stomp_attack.damage_player()
		stomp_attack.stop()
		if vision_player != null:
			start_or_continue_stomp_timer()
		stomp_attack.tween_vortex()

func take_damage(damage) -> void:
	hp -= damage
	emit_signal("boss_damaged", damage)
	var tween = get_tree().create_tween()
	# Fade to 0.5 alpha
	tween.tween_property(animations, "modulate", Color.WHITE, 0.1).from(Color.CRIMSON)
	if hp <= 0:
		boss_dead.emit()
		if !is_dead:
			audio_player.play_sound("death")
		is_dead = true
