extends Resource
class_name TerrainLayer

@export var Name: StringName = "New Layer"
@export_range(0.0, 1.0) var Threshold: float = 0.0
@export var sourceID: int
@export var AtlasCoords : Vector2i
