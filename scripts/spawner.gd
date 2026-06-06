extends Marker2D

@export var junk_scene: PackedScene
var timer1: Timer
var timer2: Timer
var timer3: Timer

func get_split_random_int() -> int:
	# randf() returns a float between 0.0 and 1.0
	if randf() < 0.5:
		return randi_range(-2000, -1000) # 50% chance for negative range
	else:
		return randi_range(1000, 2000)  # 50% chance for positive range

func spawn_enemy(health):
	var junk = junk_scene.instantiate()
	junk.global_position = Vector2(get_split_random_int(), get_split_random_int())
	junk.dir = randf() < 0.5
	junk.health = health
	print(junk.health, junk.global_position, junk.dir)
	get_parent().add_child(junk)

func _ready():
	timer1 = $Timer1
	timer2 = $Timer2
	timer3 = $Timer3
	timer1.timeout.connect(wave1)
	timer2.timeout.connect(wave2)
	timer3.timeout.connect(wave3)

func wave1():
	spawn_enemy(10)
	spawn_enemy(10)
	spawn_enemy(10)
	spawn_enemy(10)
	spawn_enemy(10)

func wave2():
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	spawn_enemy(30)
	
func wave3():
	spawn_enemy(1000)
