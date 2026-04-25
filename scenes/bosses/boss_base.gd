extends CharacterBody2D
class_name BossBase

signal boss_damaged
signal boss_dead

@export var speed: float = 100 
@export var player: Player 
@export var initial_hp: float = 1000
@export var collision_dmg_per_second: float

@onready var hp: float = initial_hp
@onready var animations: AnimatedSprite2D = get_node_or_null("Animations")
@onready var hurtbox: Area2D = get_node_or_null("Hurtbox")

signal player_entered_hurt_box(body: Node2D)
signal player_exited_hurt_box(body: Node2D)

var is_dead : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.boss_dead.connect(cleanup)

func animate(animation_name: String):
	if animations != null:
		animations.play(animation_name)

func idle():
	animate("idle")

func walk_left():
	animate("walk_left")

func walk_right():
	animate("walk_right")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		if hurtbox.overlaps_body(player):
			player.take_damage(collision_dmg_per_second*delta)
		
func take_damage(damage) -> void:
	if (is_dead): return
	
	hp -= damage
	emit_signal("boss_damaged", damage)
	var tween = get_tree().create_tween()
	tween.tween_property(animations, "modulate", Color.WHITE, 0.1).from(Color.CRIMSON)
	if hp <= 0:
		boss_dead.emit()
		is_dead = true

func cleanup():
	player = null
	speed = 0
