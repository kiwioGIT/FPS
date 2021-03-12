extends KinematicBody
var motionofset = Vector3(0,0,0)
var motion = Vector3(0,0,0)
var speed = 60
var ofset = 0.02 
var life_time = 100
var start = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _ready():
	motionofset =  Vector3(rand_range(-ofset,ofset),rand_range(-ofset,ofset),rand_range(-ofset,ofset))
	

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	motion = -global_transform.basis.z
	motion += motionofset
	motion.y-=0.01
	var collision = move_and_collide(motion * speed * delta)
	start = false
	life_time -= 1
	if life_time < 0:
		queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if !body.is_in_group("player"):
		if body.is_in_group("killable"):
			body.get_parent().queue_free()
		queue_free()
	pass # Replace with function body.
