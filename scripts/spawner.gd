extends Marker2D

@export var junk_scene: PackedScene
var timer1: Timer
var timer2: Timer
var timer3: Timer

func _ready():
	timer1 = $"../Timer1"
	timer2 = $"../Timer2"
	timer3 = $"../Timer3"
	timer1.timeout.connect(wave1)
	timer2.timeout.connect(wave2)
	timer3.timeout.connect(wave3)
	
func spawn_enemy(health):
	var junk = junk_scene.instantiate()
	junk.global_position = global_position
	junk.dir = randf() < 0.5
	junk.health = health
	get_parent().add_child(junk)

func wave1():
	spawn_enemy(10)

func wave2():
	spawn_enemy(30)
	spawn_enemy(30)

func wave3():
	spawn_enemy(50)
	spawn_enemy(50)
	spawn_enemy(50)
