## An AvatarDescriptor describes aspects of an avatar.

@tool

class_name AvatarDescriptor
extends Node3D

## The armature to animate.
@export_node_path("Skeleton3D") var skeleton: NodePath = ""

## The point where the user should see through. Place this in-between the
## avatar's eyes and in front of its face.
@export var viewpoint: Vector3 = Vector3(0, 1.5, 0)

## The collision radius.
@export var radius: float = 0.5

## The collision height above the origin.
@export var height: float = 2.0

@export_group("Bones", "bone_")

@export var bone_head: String = ""

@export var bone_left_hand: String = ""
@export var bone_left_lower_arm: String = ""
@export var bone_left_upper_arm: String = ""

@export var bone_right_hand: String = ""
@export var bone_right_lower_arm: String = ""
@export var bone_right_upper_arm: String = ""

@export var bone_hips: String = ""

@export var bone_left_foot: String = ""
@export var bone_left_lower_leg: String = ""
@export var bone_left_upper_leg: String = ""

@export var bone_right_foot: String = ""
@export var bone_right_lower_leg: String = ""
@export var bone_right_upper_leg: String = ""

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return

	DebugDraw3D.draw_arrow_line(viewpoint, viewpoint + Vector3(0, 0, 0.2), Color.BLUE, 0.2)

	DebugDraw3D.draw_cylinder(
		Transform3D(
			Basis.IDENTITY.scaled(Vector3(radius, height * 0.5, radius)),
			Vector3(0, height * 0.5, 0)
		)
	)
