extends TileMap

export(int) var PILL_TILE_ID     = 16
export(int) var PILL_BIG_TILE_ID = 17
export(int) var PACMAN_TILE_ID   = 18

var spawn_position

onready var astar = AStar.new()

# "Public" functions
#  These functions are called by other scripts (as well as this one)

# Removes the dot at a given tile position if there is one
# And fires off signals that a dot has been eaten
func eat_dot_at(pos):
    if(get_cell(pos.x, pos.y) == PILL_TILE_ID):
        set_cell(pos.x, pos.y, -1)
    if(get_cell(pos.x, pos.y) == PILL_BIG_TILE_ID):
        set_cell(pos.x, pos.y, -1)

# Checks that a tile at a position is a wall
func tile_at_pos_is_wall(pos):
    return tile_id_is_wall(get_cell(pos.x, pos.y))

# "Private" methods
func _ready():
    set_process_input(true)
    make_walls_tile_aware()
    set_spawn_position()

func _input(event):
    if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1 and event.is_pressed() and !event.is_echo()):
        toggle_wall_at(world_to_map_with_offset(event.pos))

func world_to_map_with_offset(pos):
    pos -= get_global_pos()
    return world_to_map(pos)

func toggle_wall_at(pos):
    if tile_id_is_wall(get_cell(pos.x, pos.y)):
        set_cell(pos.x, pos.y, -1)
    else:
        set_cell(pos.x, pos.y, 0)
    make_walls_tile_aware()

# TILE AWARE REGION
func make_walls_tile_aware():
    for cell in get_used_cells():
        if(tile_id_is_wall(get_cell(cell.x, cell.y))):
            var north = tile_id_is_wall(get_cell(cell.x, cell.y - 1))
            var east  = tile_id_is_wall(get_cell(cell.x + 1, cell.y))
            var south = tile_id_is_wall(get_cell(cell.x, cell.y + 1))
            var west  = tile_id_is_wall(get_cell(cell.x - 1, cell.y))

            var tile = north*1 + west*2 + south*4 + east*8
            set_cell(cell.x, cell.y, tile)

func tile_id_is_wall(id):
    return (id >= 0 && id <= 15)
#END TILES AWARE

func set_spawn_position():
    for cell in get_used_cells():
        if(get_cell(cell.x, cell.y) == PACMAN_TILE_ID):
            spawn_position = cell
            set_cell(cell.x, cell.y, -1)
            return
    print("No spawn position in map!")
    spawn_position = Vector2(-1, -1)
