extends CharacterBody3D

@export var speed: float = 7.0 
@export var max_health: float = 3.0
#boring ahhhhhh
@onready var ray_forward: RayCast3D = $FrontRay
@onready var ray_left: RayCast3D = $LeftRay
@onready var ray_right: RayCast3D = $RightRay

var was_left_wall: bool = true
var was_right_wall: bool = true
var was_forward_wall: bool = false


var _current_health = 0

func _ready() -> void:
	_current_health = max_health
	
func _take_damage(damage: float):
	_current_health -= damage
	
	if _current_health <= 0:
		_die()
		
func _die():
	queue_free()


func _physics_process(delta: float) -> void:
	#force raycast update each frame
	ray_forward.force_raycast_update()
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	
	var current_forward_wall: bool = ray_forward.is_colliding()
	var current_left_wall: bool = ray_left.is_colliding()
	var current_right_wall: bool = ray_right.is_colliding()
	
	var trigger_decision: bool = false
	
	#break shankars nose (detect wall)
	if current_forward_wall:
		trigger_decision = true
	
	#Detect new fork on left, wall -> gap
	if not current_left_wall and was_left_wall:
		trigger_decision = true
	
	#detect gap on right, wall -> gap
	if not current_right_wall and was_right_wall:
		trigger_decision = true
	
	if trigger_decision:
		#spidey sense the available directions
		var options: Array[String] = []
		if not current_forward_wall:
			options.append("forward")
		if not current_left_wall:
			options.append("left")
		if not current_right_wall:
			options.append("right")
		
		if options.is_empty():
			#we bailing out at dead ends
			rotate_y(PI)
		else:
			#randomly pik a direction
			var choice: String = options[randi() % options.size()]
			if choice == "left":
				rotate_y(PI / 2.0)  #left
			elif choice == "right":
				rotate_y(-PI / 2.0)  #right
		#fk the other directoins
	
	#pull a javascript and keep moving forward 
	var forward_dir: Vector3 = -transform.basis.z.normalized()
	velocity = forward_dir * speed
	move_and_slide()
	
	#update previous states for next frame type shi
	was_forward_wall = current_forward_wall
	was_left_wall = current_left_wall
	was_right_wall = current_right_wall


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("dead")
	get_tree().change_scene_to_file("res://death_cutscene.tscn")
