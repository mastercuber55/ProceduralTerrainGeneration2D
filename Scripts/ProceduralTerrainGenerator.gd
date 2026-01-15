extends Node2D

@export var config: GenerationRules
@export var TerrainCurve: Curve

@export var TerrainLevels: Array[TerrainLayer] = []

var noise := FastNoiseLite.new()
var chunks = {}
var lastChunkCoords : Vector2i

@onready var ground := $"."

func _ready() -> void:
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.05

func _process(_delta: float) -> void:
	var playerPos = %Player.global_position
	
	var chunkCoords = Vector2i(
		floor(playerPos.x / (config.chunk_size * config.tile_size)),
		floor(playerPos.y / (config.chunk_size * config.tile_size))
	)
	if chunkCoords != lastChunkCoords:
		updateChunks(chunkCoords)
		lastChunkCoords = chunkCoords

func updateChunks(chunkCoords: Vector2i):
	for x in range(chunkCoords.x - 2, chunkCoords.x + 3):
		for y in range(chunkCoords.y - 2, chunkCoords.y + 3):
			var targetChunk = Vector2i(x, y)
			if not chunks.has(targetChunk):
				generateChunk(targetChunk)
				chunks[targetChunk] = true # marking as Active -> true
				
	for chunk in chunks.keys():
		if 	abs(chunk.x - chunkCoords.x) > config.render_distance or\
			abs(chunk.y - chunkCoords.y) > config.render_distance:
				removeChunk(chunk)
				chunks.erase(chunk)

# TODO: make each plant be a dedicated scene with health and animation
func generateTree(n, pos):
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(pos) + n

func getTile(x: int, y: int) -> TerrainLayer:
	var rawNoise = noise.get_noise_2d(x, y)
	# convert from [-1, 1] to [0, -1] for curves
	var normalizedNoise = (rawNoise + 1.0) / 2.0
	var curvedHeight = TerrainCurve.sample(normalizedNoise)
	
	for layer in TerrainLevels:
		if curvedHeight <= layer.Threshold:
			return layer
	return null
	
func generateChunk(chunk: Vector2i):
	var start = chunk * config.chunk_size
	#var groupTiles : Array[Vector2i] = []
	
	for x in range(start.x, start.x + config.chunk_size):
		for y in range(start.y, start.y + config.chunk_size):
			var tile := getTile(x, y)
			if tile == null:
				continue
			ground.set_cell(Vector2i(x, y), tile.sourceID, tile.AtlasCoords)
	#if groupTiles.is_empty():
		#return
	
	#ground.set_cells_terrain_connect(groupTiles, 0, 0)
	
func removeChunk(chunk: Vector2i):	
	var start = chunk * config.chunk_size
	
	for x in range(start.x, start.x + config.chunk_size):
		for y in range(start.y, start.y + config.chunk_size):
			ground.set_cell(Vector2i(x, y), -1)
