extends CharacterBody3D

## Movement speed multiplier.
const SPEED := 5.0

## Initial Y velocity of jump.
const JUMP_VELOCITY := 4.5

## Maximum rotation speed in radians per second.
const ROT_SPEED := 3.0

## Temporary magic number for sitting height adjustment.
const SIT_ADJUST := 0.3

## Mouse speed rotation for looking around.
const LOOK_SPEED := -0.001

## Maximum neck angle before body automatically rotates.
const MAX_NECK_ROTATION := 0.3

## Acceleration from gravity.
static var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## The XR interface that has been initialized, or null.
var xr_interface: XRInterface = null

## If true, XR should be used. This changes how inputs are handled.
var using_xr := false

## If true, user is in sitting mode. This adjusts their height to account for
## their lower position due to being seated.
var sitting := false

# XR origin.
@onready var origin: XROrigin3D = %Origin

# XR nodes.
@onready var head: XRCamera3D = %Head
@onready var left_hand: HandController = %LeftHand
@onready var right_hand: HandController = %RightHand

# Fake lower body tracking.
@onready var targets: Node3D = %Targets
@onready var hips: Node3D = %Hips

# Main IK controller.
@onready var renik: RenIK3D = %RenIK

func _ready() -> void:
	# Attempt to load OpenXR
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
		using_xr = true
	else:
		print("No OpenXR found")
		xr_interface = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			head.rotate_y(event.relative.x * LOOK_SPEED)
			head.rotate_x(event.relative.y * LOOK_SPEED)
			head.rotation.z = 0
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(_delta: float) -> void:
	# Rotate ourselves if neck turns far.
	var diff := MathUtil.angle_diff(head.global_rotation.y, targets.global_rotation.y)
	if diff < -MAX_NECK_ROTATION:
		targets.rotate_y(-diff - MAX_NECK_ROTATION)
	elif diff > MAX_NECK_ROTATION:
		targets.rotate_y(-diff + MAX_NECK_ROTATION)
	# Place hip in-between head and root of player.
	hips.global_position = head.global_position
	hips.global_position.y = lerpf(
		global_position.y,
		head.global_position.y,
		0.618,
	)
	# Update the IK.
	renik.update_ik()

func _jump_pressed() -> bool:
	if using_xr:
		return right_hand.get_ax().pressed()
	else:
		return Input.is_action_just_pressed("jump")

func _sit_pressed() -> bool:
	if using_xr:
		return right_hand.get_by().pressed()
	else:
		return Input.is_action_just_pressed("sit_mode")

func _handle_gravity(delta: float) -> void:
	velocity.y -= gravity * delta

func _handle_jump() -> void:
	if _jump_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _handle_xz_movement() -> void:
	# Choose where to get movement input.
	var input_dir: Vector2
	if using_xr:
		input_dir = left_hand.get_stick()
	else:
		input_dir = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	# Calculate direction.
	var direction := (transform.basis * head.transform.basis * Vector3(input_dir.x, 0, -input_dir.y)).limit_length(1.0) * SPEED
	# Update velocity.
	velocity.x = direction.x
	velocity.z = direction.z

func _handle_turning(delta: float) -> void:
	var turn_axis: float
	if using_xr:
		turn_axis = right_hand.get_stick().x
		# temporary deadzone
		if absf(turn_axis) < 0.2:
			turn_axis = 0.0
	else:
		turn_axis = Input.get_axis("look_left", "look_right")
	rotate_y(-turn_axis * ROT_SPEED * delta)

func _handle_sitting() -> void:
	if using_xr and _sit_pressed():
		sitting = not sitting
		if sitting:
			origin.position.y = SIT_ADJUST
		else:
			origin.position.y = 0

func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_jump()
	_handle_xz_movement()
	_handle_turning(delta)
	_handle_sitting()
	move_and_slide()
