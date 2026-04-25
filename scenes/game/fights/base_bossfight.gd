extends Node2D
class_name BossfightBase

signal win
signal lose


@onready var boss_healthbar = $BossHealthbar
@onready var player_healthbar = $PlayerHealthbar
@onready var boss = $Boss
@onready var player = $Player

@export var enter_transition_duration: float = 1

var boss_hp
var player_hp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boss_healthbar.value = 100
	player_healthbar.value = 100
	boss_hp = boss.initial_hp
	player_hp =  player.initial_hp
	boss.connect("boss_damaged", _on_boss_damaged)
	boss.boss_dead.connect(_on_boss_dead)
	player.connect("player_damaged", _on_player_damaged)	
	player.player_dead.connect(_on_player_dead)
	
	create_bounce_tween()
	pass # Replace with function body.

func create_bounce_tween():
	var tween = get_tree().create_tween()
		
	# Tween the position
	tween.tween_property(player, "position", $PlayerEnterPosition.position, enter_transition_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(boss, "position", $BossEnterPosition.position, enter_transition_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.finished.connect(boss.on_arena_enter_tween_finish)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_boss_damaged(damage) -> void:
	boss_hp -= damage
	boss_healthbar.value = 100*(boss_hp/boss.initial_hp)
	
func _on_player_damaged(damage) -> void:
	player_hp -= damage
	player_healthbar.value = 100*(player_hp/player.initial_hp)

func _on_boss_dead():
	print("BOSS IS DEAD")
	emit_signal("win")

func _on_player_dead():
	print("PLAYER IS DEAD")
	emit_signal("lose")
