extends KinematicBody

var velocity = Vector3()
const ACCELERATION = 8
const DE_ACCELERATION = 10
const MOVE_SPEED = 24
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
 
onready var cam = $CamBase
var move_vec = Vector3()
 
var y_velo = 0
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
	var move_vec = Vector3()
	if Input.is_action_pressed("FORWARD"):
		move_vec.z -= 1
	if Input.is_action_pressed("BACKWARD"):
		move_vec.z += 1
	if Input.is_action_pressed("RIGHT"):
		move_vec.x += 1
	if Input.is_action_pressed("LEFT"):
		move_vec.x -= 1
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec = move_vec.normalized()
	move_vec.y = 0
	
	
	var grounded = is_on_floor()
	velocity.y -= GRAVITY
	var just_jumped = false
	if grounded and Input.is_action_just_pressed("JUMP"):
		just_jumped = true
		velocity.y = JUMP_FORCE
	if grounded and velocity.y <= 0:
		velocity.y = -0.1
	if velocity.y < -MAX_FALL_SPEED:
		velocity.y = -MAX_FALL_SPEED
	
	if Input.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var hv = velocity
	hv.y = 0
	var new_pos = move_vec * MOVE_SPEED
	var accel = DE_ACCELERATION
	if (move_vec.dot(hv) > 0):
		accel = ACCELERATION
	if !grounded:
		accel = accel/3
	hv = hv.linear_interpolate(new_pos, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z
	velocity = move_and_slide(velocity, Vector3(0,1,0))
