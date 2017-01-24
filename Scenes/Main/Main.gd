extends Node

# References to game nodes
onready var tilemap = get_node("Tilemap")
# Pacman is a child of tilemap because Tilemap is slightly offset so that
# it's centered in the screen, pacman being a child means he can use local
# position and always be aligned without needing to adjust for the tilemap offset
onready var pacman = get_node("Tilemap/Pacman")

func _ready():
    pacman.set_hidden(true)
    start_game()
    set_process(true)

func _enter_tree():
    get_node("Tilemap")

func start_game():
    place_pacman()
    pacman.set_process(true)

# Tells tilemap to remove the pacman tile and then we move the pacman node
# to where the tile was
func place_pacman():
    # Sets the tilemaps spawn position based on the pacman
    if(tilemap.spawn_position == null):
        tilemap.set_spawn_position()

    # Place pacman in his position
    var cell_size = tilemap.get_cell_size()
    var pac_x = (tilemap.spawn_position.x * cell_size.x)
    var pac_y = (tilemap.spawn_position.y * cell_size.y)
    pacman.set_tilemap_position(Vector2(pac_x, pac_y))

    # Unhide him
    pacman.set_hidden(false)
