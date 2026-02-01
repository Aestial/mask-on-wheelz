@abstract
class_name CarBase
extends VehicleBody3D

@export_category("Car Settings")
## Max steer in radians for the front wheels- defaults to 0.45
@export var max_steer : float = 0.45
## The maximum torque that the engine will sent to the rear wheels- defaults to 300
@export var max_torque : float = 300.0
## The maximum amount of braking force applied to the wheel. Default is 1.0
@export var max_brake_force : float = 1.0
## The maximum rear wheel rpm. The default value is 600rpm
## The actual engine torque is scaled in a linear vector to ensure the rear wheels will never go beyond this given rpm.
@export var max_wheel_rpm : float = 600.0
## How quickly the wheel responds to player input- equates to seconds to reach maximum steer. Default is 2.0
@export var steer_damping : float = 2.0
## How sticky are the front wheels. Default is 5. 0 is frictionless._add_constant_central_force
@export var front_wheel_grip : float = 5.0
## How sticky are the rear wheel. Default is 5. Try lower value for a more drift experience
@export var rear_wheel_grip : float = 5.0
## How front wheels resist vehicle body roll, 0.0 value means prone to roll over.
@export var front_wheel_roll_influence : float = 1.0
## How rear wheels resist vehicle body roll. If set 1.0 for all wheels, vehicle will resist to roll. 
@export var rear_wheel_roll_influence : float = 1.0

## Difficulty/Behavior Settings
@export_category("Behaviour Settings")
@export var aggressiveness : float = 1.0		# How aggressive the car is (0 - 2)
@export var skill_level : float = 1.0		# Affects steering precision, braking timing (0.5 - 1.5)	
@export var reaction_time : float = 0.2		# Delay in reaction (seconds)

# Protected variables for derived classes
var _current_acceleration : float = 0.0
var _current_braking : float = 0.0
var _current_steer : float = 0.0
var _target_input : Vector2 = Vector2.ZERO

# References to wheels
# An exporetd array of driving wheels so we can limit rom of each wheel when we process input
@onready var driving_wheels : Array[VehicleWheel3D] = [$WheelBackLeft,$WheelBackRight]
@onready var steering_wheels : Array[VehicleWheel3D] = [$WheelFrontLeft,$WheelFrontRight]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set wheel friction slip and roll influence
	for wheel in steering_wheels:
		wheel.wheel_friction_slip = front_wheel_grip * skill_level
		wheel.wheel_roll_influence = front_wheel_roll_influence * skill_level
	for wheel in driving_wheels:
		wheel.wheel_friction_slip = rear_wheel_grip * skill_level
		wheel.wheel_roll_influence = rear_wheel_roll_influence * skill_level
		
func _physics_process(delta: float) -> void:
	calculate_desired_input(delta)	
	# Apply reaction time delay
	_target_input = lerp(_target_input, get_desired_input(), delta / (reaction_time + 0.01))
	process_input(delta)
	# Apply to vehicle
	apply_controls(delta)
	
@abstract func calculate_desired_input(delta: float)

@abstract func get_desired_input() -> Vector2
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_input(delta: float):
	# Process stering with damping 
	var desired_steer : float = _target_input.x * max_steer	* skill_level
	_current_steer = move_toward(_current_steer, desired_steer, steer_damping * delta)
	
	# Process acceleration/braking
	if _target_input.y > 0.01:
		# Accelerating
		_current_acceleration = _target_input.y * aggressiveness
		_current_braking = 0.0
	elif _target_input.y < -0.01:
		# Braking or reversing
		if going_forward():
			_current_braking = -_target_input.y * max_brake_force * aggressiveness
			_current_acceleration = 0.0
		else:
			_current_braking = 0.0
			_current_acceleration = _target_input.y
	else: 
		_current_acceleration = 0.0
		_current_braking = 0.0
		
func apply_controls(delta: float):
	steering = _current_steer
	brake = _current_braking
		
	# Apply engine force with RPM limiting
	for wheel in driving_wheels:
		var actual_force : float = _current_acceleration * max_torque * skill_level
		actual_force *= clamp(1.0 - abs(wheel.get_rpm()) / max_wheel_rpm, 0.1, 1.0)
		wheel.engine_force = actual_force

func going_forward() -> bool:
	var relative_speed : float = basis.z.dot(linear_velocity.normalized())
	return relative_speed > 0.01
	
func get_speed_kmh() -> float:
	return linear_velocity.length() * 3.6
	
func set_difficulty_params(agressive: float, skill: float, reaction: float):
	self.aggressiveness = agressive
	self.skill_level = skill
	self.reaction_time = reaction