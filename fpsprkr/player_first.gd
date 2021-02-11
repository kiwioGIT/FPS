extends KinematicBody

onready var animplayer = get_node("cat_rigged/AnimationPlayer")
var velocity = Vector3()
const ACCELERATION = 8
const DE_ACCELERATION = 8
const MOVE_SPEED = 34
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
var proceduralrotation = 0
var gunRot = 0
const MODELROTSPEED = 8
var bullet_scn = preload("res://Bullet.tscn")
var slide = false
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
var shootcooldown = 0
onready var staticCam = get_node("CamStaticBase")
onready var cam = staticCam.get_node("CamBase")
var move_vec = Vector3()
 
var y_velo = 0


func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
		get_node("GunBase").rotation_degrees.x = cam.rotation_degrees.x
		
 
func _physics_process(delta):
	shootcooldown -=1 * delta
	var finalrotation = 0
	var move_vec = Vector3()
	if Input.is_action_pressed("BACKWARD"):
		move_vec.z += 1
	if Input.is_action_pressed("RIGHT"):
		move_vec.x += 1
		finalrotation -= 90
	if Input.is_action_pressed("LEFT"):
		move_vec.x -= 1
		finalrotation += 90
	if Input.is_action_pressed("FORWARD"):
		move_vec.z -= 1
		finalrotation = finalrotation/2
	elif Input.is_action_pressed("BACKWARD"):
		move_vec.z += 1
		if Input.is_action_pressed("LEFT"):
			finalrotation += 45
		elif Input.is_action_pressed("RIGHT"):
			finalrotation -= 45
		else:
			finalrotation += 180
	if Input.is_action_pressed("slide"):
		slide = true
	else:
		slide = false
	if Input.is_action_just_pressed("shoot"):
		if shootcooldown < 0:
			var new_bullet = bullet_scn.instance()
			get_tree().get_root().add_child(new_bullet)
			new_bullet.global_transform = cam.global_transform
			new_bullet.global_transform
			shootcooldown = 0.2
		pass
	
	
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec = move_vec.normalized()
	move_vec.y = 0
	
	if Input.is_action_just_pressed("slide"):
		staticCam.translate(Vector3(0,-1,0))
	if Input.is_action_just_released("slide"):
		staticCam.translate(Vector3(0,1,0))
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
	elif Input.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_key_pressed(KEY_U):
		if velocity.y < 30: 
			velocity.y += 5
	
	var hv = velocity
	hv.y = 0
	var new_pos = move_vec * MOVE_SPEED
	var accel = DE_ACCELERATION
	if (move_vec.dot(hv) > 0):
		if !slide:
			accel = ACCELERATION
		else:
			accel = 0
	else:
		if slide:
			accel/= 3
	if !is_on_floor():
		accel = accel/8
	hv = hv.linear_interpolate(new_pos, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z
	velocity = move_and_slide(velocity, Vector3(0,1,0))
