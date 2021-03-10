extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var p

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	p=get_node("player").get_node("CamStaticBase/CamBase").rotation_degrees
	get_node("Bullet").get_node("TrailRenderer").rotation_degrees = p
