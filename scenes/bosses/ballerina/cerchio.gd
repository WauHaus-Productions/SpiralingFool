extends Area2D

signal player_hitted
var rng = RandomNumberGenerator.new()

@export var speed = rng.randf_range(10, 12)
@export var cooldown = 0.2
@onready var audio_collision = $Collision
@onready var audio_in_flight = $In_flight

var direction
var player_position
var distance_from_player
var boss_position
var distance_from_boss
var player

var change_direction = true
var start_cooldown = false
var despawnable = false
var despawned = false

var circular_offset
var circular_offset_rotated
var radius = rng.randf_range(2, 4) # Radius of the circular motion
var angular_speed = rng.randf_range(50, 70)
# Angular speed for circular motion (radians per second)
var time_passed = 0.0 # Keeps track of elapsed time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_in_flight.play()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	circular_offset = Vector2(cos(time_passed * angular_speed), sin(time_passed * angular_speed)) * radius
	circular_offset_rotated = circular_offset.rotated(direction.angle())
	self.position += direction*speed*delta*130 + circular_offset_rotated
	distance_from_player = player_position.distance_to(global_position)
	distance_from_boss = boss_position.distance_to(global_position)
	if self.overlaps_body(self.player):
		emit_signal("player_hitted", delta)
			
	if (distance_from_player < 50):
		start_cooldown = true
	if start_cooldown == true:
		cooldown -= delta
	if cooldown < 0 and change_direction == true:
		direction = -direction
		change_direction = false
		despawnable = true
	if despawnable == true and distance_from_boss < 100:
		despawned = true
		$CollisionShape2D.disabled = true
		hide()
	
