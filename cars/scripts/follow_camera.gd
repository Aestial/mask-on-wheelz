extends Node3D

@export_category("Follow Camera Settings")
# Must be a vehicle body
@export var follow_target : Node3D
@export_range(0.0,10.0) var camera_height : float = 2.0
@export_range(1.0,20.0) var camera_distance : float = 5.0
@export_range(0.0,10.0) var rotation_damping: float = 1.0

@export_category("Look Back Settings")
@export var look_back_action : String = "look_back"
@export_range(0.0, 5.0) var look_back_distance : float = 3.0
@export_range(0.0, 180.0) var look_back_angle : float = 180.0
@export_range(0.0,10.0) var look_back_damping: float = 5.0
@export var invert_look_back : bool = false

#locals
@onready var pivot : Node3D = $Pivot
@onready var springarm : SpringArm3D = $Pivot/SpringArm3D

var is_looking_back : bool = false
var target_rotation_offset : float = 0.0
var current_rotation_offset : float = 0.0

func _ready() -> void:
	pivot.position.y = camera_height
	springarm.spring_length = camera_distance


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Handle look back input 
	is_looking_back = Input.is_action_pressed(look_back_action)
	
	# Set target rotation offset based on look back state
	if is_looking_back:
		target_rotation_offset = deg_to_rad(look_back_angle) * (-1 if invert_look_back else 1)
	else:
		target_rotation_offset = 0.0
	
	# Smoothly interpolate current rotation offset
	var weight : float = look_back_damping * delta
	current_rotation_offset = lerp(current_rotation_offset, target_rotation_offset, weight)
	
	global_position = follow_target.global_position
	
	var target_forward: Vector3 = follow_target.global_basis.z.slide(Vector3.UP).normalized()	
	var rotated_forward: Vector3 = target_forward.rotated(Vector3.UP, current_rotation_offset)
	var desired_basis: Basis = Basis.looking_at(-rotated_forward, Vector3.UP)
	
	global_basis = global_basis.slerp(desired_basis, rotation_damping * delta)
	
	if is_looking_back:
		springarm.spring_length = look_back_distance
	else:
		springarm.spring_length = camera_distance
		
