extends CharacterBody3D


const WALK_SPEED := 11.0
const SPRINT_MULT := 1.5
const SNEAK_MULT := 0.45
const SLIDE_SPEED := 18.0
const SLIDE_JUMP_BOOST := 1.25
const JUMP_VELOCITY := 10.0
const AIR_CONTROL := 0.35


const MANTLE_HEIGHT := 1.4
const MANTLE_FORCE := 6.5

@export var mouse_sensitivity := 0.07


const BOB_FREQ := 10.0
const BOB_AMP := 0.06


const TILT_AMOUNT := 6.0
const TILT_SPEED := 10.0

const STAND_HEIGHT := 1.8
const CROUCH_HEIGHT := 1.0
const RESIZE_SPEED := 8.0

@onready var head: Node3D = $head
@onready var camera: Camera3D = $head/Camera3D
@onready var collider: CollisionShape3D = $CollisionShape3D


@onready var mantle_low: RayCast3D = $MantleLow
@onready var mantle_high: RayCast3D = $MantleHigh

#state
var rotation_x := 0.0
var bob_time := 0.0

var sliding := false
var crouching := false
var slide_timer := 0.0
const SLIDE_TIME := 0.6

#init by capturing mosue
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#input
func _input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -90.0, 90.0)
		head.rotation_degrees.x = rotation_x

	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#physucs main
func _physics_process(delta: float) -> void:
	#gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	#jump mantle and slide jump (spacebar stuff)
	if Input.is_action_just_pressed("jump"):
		if sliding:
			#slide jump
			var forward := -global_transform.basis.z
			velocity.x = forward.x * SLIDE_SPEED * SLIDE_JUMP_BOOST
			velocity.z = forward.z * SLIDE_SPEED * SLIDE_JUMP_BOOST
			velocity.y = JUMP_VELOCITY
			sliding = false
		elif try_mantle():
			return
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY

	#Movement input
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var sprinting := Input.is_action_pressed("ctrl")
	var shift_pressed := Input.is_action_just_pressed("shift")

	#slide nd crouch (shift stuff)
	if shift_pressed and is_on_floor():
		if input_dir != Vector2.ZERO:
			sliding = true
			crouching = false
			slide_timer = SLIDE_TIME
			velocity.x = direction.x * SLIDE_SPEED
			velocity.z = direction.z * SLIDE_SPEED
		else:
			crouching = true
			sliding = false

	if Input.is_action_just_released("shift"):
		crouching = false

	#sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0.0:
			sliding = false

	#sprint nd crouch nd walk speed
	var speed := WALK_SPEED
	if sprinting and not crouching:
		speed *= SPRINT_MULT
	elif crouching:
		speed *= SNEAK_MULT

	#movement direction
	if not sliding:
		var control := AIR_CONTROL if not is_on_floor() else 1.0
		velocity.x = direction.x * speed * control
		velocity.z = direction.z * speed * control

	#head bob
	if is_on_floor() and direction != Vector3.ZERO and not sliding:
		bob_time += delta * BOB_FREQ
	else:
		bob_time = 0.0

	head.position.y = lerp(
		head.position.y,
		sin(bob_time) * BOB_AMP,
		10.0 * delta
	)

	#tilt **maybe remove this its annoying
	camera.rotation_degrees.z = lerp(
		camera.rotation_degrees.z,
		-input_dir.x * TILT_AMOUNT,
		TILT_SPEED * delta
	)

	#change capsule size when sneaking
	var capsule := collider.shape as CapsuleShape3D
	var target_height := STAND_HEIGHT

	if crouching or sliding:
		target_height = CROUCH_HEIGHT

	capsule.height = lerp(
		capsule.height,
		target_height,
		RESIZE_SPEED * delta
	)

	move_and_slide()

#mantling
func try_mantle() -> bool:
	if is_on_floor():
		return false

	if mantle_low.is_colliding() and not mantle_high.is_colliding():
		velocity.y = MANTLE_FORCE
		global_position.y += MANTLE_HEIGHT * 0.5
		return true

	return false
