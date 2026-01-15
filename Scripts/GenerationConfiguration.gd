extends Resource
class_name GenerationRules

@export_group("Chunk Settings")
@export var chunk_size: int = 8
@export var tile_size: int = 16
@export var render_distance: int = 2

@export_group("Noise Settings")
@export var frequency: float = 0.05
@export var noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_PERLIN

#@export_group("Terrain and Foliage")
#
#@export var terrain_levels: Array[Dictionary] = [
	#{ "max": -0.4, "tile": "Dirt" },
	#{ "max": 0.0,  "tile": "Plain Grass" },
	#{ "max": 0.2,  "tile": "Grassy Grass" },
	#{ "max": 1.0,  "tile": "Flowery Grass" }
#]
#
#@export var plant_chances: Array[Dictionary] = [
	#{ "chance": 0.002, "tile": Vector2i(5, 2) },
	#{ "chance": 0.010, "tile": Vector2i(4, 0) },
	#{ "chance": 0.020, "tile": Vector2i(4, 2) },
	#{ "chance": 0.030, "tile": Vector2i(5, 0) },
	#{ "chance": 0.070, "tile": Vector2i(5, 1) }
#]
