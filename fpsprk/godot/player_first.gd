extends KinematicBody

onready var animplayer = get_node("cat_rigged/AnimationPlayer")
var velocity = Vector3()
const ACCELERATION = 8
const DE_ACCELERATION = 8
const MOVE_SPEED = 34
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 100
var proceduralrotation = 0
var gunRot = 0
const MODELROTSPEED = 8
var bullet_scn = preload("res://Bullet.tscn")
var slide = false
const H_LOOK_SENS = 0.3
const V_LOOK_SENS = 0.3
var shootcooldown = 0
onready var staticCam = get_node("CamStaticBase")
onready var cam = staticCam.get_node("CamBase")
onready var staticGun = get_node("StaticGunBase")
onready var gun = staticGun.get_node("GunBase")
var max_jet_speed = 50
var jet_speed = 3
var move_vec = Vector3()
var camdistance = 0
var y_velo = 0
onready var bodyAnim = get_node("PlayerGraphics/BodyPlayer")

func _ready():
	if camdistance == 0:
		get_node("PlayerGraphics").visible = false
	else:
		get_node("PlayerGraphics").visible = true
	#bodyAnim.set_loop(true)
	bodyAnim.play("run")


func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
		gun.rotation_degrees.x = cam.rotation_degrees.x
		
 
func _physics_process(delta):
	shootcooldown -=1 * delta
	var finalrotation = 0
	var move_vec = Vector3()
	if !slide:
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
			get_node("StaticGunBase/GunBase/AnimationPlayer").play("shooting")
			shootcooldown = 0.2
		pass
	
	
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec = move_vec.normalized()
	move_vec.y = 0
	if Input.is_action_just_pressed("pers"):
		cam.get_node("Camera").translate(Vector3(0,0,5))
		camdistance += 1
		if camdistance == 0:
			get_node("PlayerGraphics").visible = false
		else:
			get_node("PlayerGraphics").visible = true
	if Input.is_action_just_released("pers2"):
		cam.get_node("Camera").translate(Vector3(0,0,-5))
		camdistance -= 1
		if camdistance == 0:
			get_node("PlayerGraphics").visible = false
		else:
			get_node("PlayerGraphics").visible = true
	if Input.is_action_just_pressed("slide"):
		staticCam.translate(Vector3(0,-1,0))
		staticGun.translate(Vector3(0,-1,0))
		get_node("CollisionShape").scale.z = 1
	if Input.is_action_just_released("slide"):
		get_node("CollisionShape").scale.z = 3
		staticCam.translate(Vector3(0,1,0))
		staticGun.translate(Vector3(0,1,0))
	var grounded = is_on_floor()
	velocity.y -= GRAVITY
	var just_jumped = false
	if grounded and Input.is_action_pressed("JUMP"):
		just_jumped = true
		velocity.y = JUMP_FORCE
	if grounded and velocity.y <= 0:
		velocity.y = -0.1
	if velocity.y < -MAX_FALL_SPEED:
		velocity.y = -MAX_FALL_SPEED
	elif Input.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_key_pressed(KEY_U):
		if velocity.y < max_jet_speed: 
			velocity.y += jet_speed
		else:
			velocity.y = max_jet_speed
	
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
			accel/= 6
	if !is_on_floor():
		accel = accel/8
	hv = hv.linear_interpolate(new_pos, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z
	velocity = move_and_slide(velocity, Vector3(0,1,0))
