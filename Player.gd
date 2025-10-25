extends CharacterBody3D


const SPEED = 10.0


@export var mouse_sensitivity: float = 0.07
@onready var head: Node3D = $head

var rotation_x := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -90, 90)
		head.rotation_degrees.x = rotation_x

	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event.is_action_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta		

	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
