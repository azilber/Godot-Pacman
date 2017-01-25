
extends Sprite

export(int) var speed = 100 # How many pixels this ghost moves per second

# Pathfinding
onready var tilemap = get_parent()
var current_path = []
var previous_position = get_pos() # Store this so that we can calculate the direction the ghost is heading

const DIRECTIONS = {
    LEFT  = 0,
    RIGHT = 1,
    UP    = 2,
    DOWN  = 3
}

func _ready():
    set_process(true)
    #set_process_input(true)

func _input(event):
    if event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1 and event.is_pressed() and !event.is_echo():
        var clicked_tile = tilemap.world_to_map_with_offset(event.pos)
        var ghost_tile   = tilemap.world_to_map(get_pos())
        current_path = tilemap.get_path_to_from(clicked_tile, ghost_tile)

    if event.type == InputEvent.MOUSE_BUTTON and event.button_index == 2 and event.is_pressed() and !event.is_echo():
        set_pos(event.pos - tilemap.get_pos())
        current_path = []

func _process(delta):
    #handle_movement_to_a_path(delta)
    handle_movement_random(delta)

    update() #Debug

# Draws current_path to the screen (for debugging pathfinding)
func _draw():
    for pos in current_path:
        draw_circle(Vector2(pos.x, pos.y) + Vector2(8, 8) - get_pos() , 3, Color(1, 0, 0, 1))

# Handles the movement of ghost
func handle_movement_to_a_path(delta):
    if current_path.size() <= 0:
        return

    # Before we move set the previous position of the ghost
    previous_position = get_pos()

    var target_pos = Vector2(current_path[0].x, current_path[0].y)

    # If we're not at our direction yet (or we just got a new one) move towards it
    var move_direction = (target_pos - get_pos()).normalized()
    set_pos(get_pos() + (move_direction * speed * delta))

    if get_pos().distance_to(target_pos) < 1:
        set_pos(target_pos)
        current_path.remove(0)

# Handles the movement of ghost randomly
# Ghost checks every time he moves a tile in which directions he can move
# Then picks one that isn't the way he came unless it's a dead end
# Uses current_path to store where to move
func handle_movement_random(delta):
    if current_path.size() <= 0:
        # If there is no path get a random moveable direction and set it as the current_path
        current_path.append(get_random_moveable_direction())

    # We already have a method to move along a path so call that
    handle_movement_to_a_path(delta)

# Gets a random position for the ghost to move
# Takes into account direction ghost came from and will only
# move in that direction if no other directions are available
func get_random_moveable_direction():
    # Get the current position of the ghost
    var current_pos = tilemap.world_to_map(get_pos())

    # Get all 4 directions a ghost can move relative from the current position
    # For left we check -1 tile to the left on the x axis and y stays the same

    # Store the tilemap positions of each direction
    var dir_tile_positions = []

    # Resize the array to fit 4 directions
    dir_tile_positions.resize(4)

    # Because we resized the array we can put the positions in in any order,
    # and insert using the constant corresponding directions int
    # This keeps the code easier to read as well as not
    # getting funky bugs if the DIRECTIONS are inserted into dir_tile_positions some wrong order
    dir_tile_positions[DIRECTIONS.LEFT]  = Vector2(current_pos.x - 1, current_pos.y)
    dir_tile_positions[DIRECTIONS.RIGHT] = Vector2(current_pos.x + 1, current_pos.y)
    dir_tile_positions[DIRECTIONS.UP]    = Vector2(current_pos.x, current_pos.y - 1)
    dir_tile_positions[DIRECTIONS.DOWN]  = Vector2(current_pos.x, current_pos.y + 1)

    # Open an array to store the directions the ghost can move into
    var moveable_directions = []

    # Find the direction we are currently headed
    # This is so that the ghost doesnt randomly turn around whilst heading down a corridor
    var current_dir = get_current_direction_id()

    # Check all directions for walls, we use range so that it checks with the number of the DIRECTIONS
    for direction in range(dir_tile_positions.size()):
        # If any of the directions are NOT a wall we add them to the moveable_directions array
        if not tilemap.tile_at_pos_is_wall(dir_tile_positions[direction]):
            moveable_directions.append(direction)

    # If there are no moveable_directions something has gone wrong
    # Instead of crashing by returning moveable_directions[0] which wont exist we return our current position
    # Effectively making the ghost stand still, also cry about it in the output
    if moveable_directions.size() == 0:
        print("No moveable path for ghost")
        return get_pos()

    # If there is more than 1 position the ghost can move into that means the
    # ghost does not have to turn around, so we can remove that direction from the array
    # before we randomly pick one
    if moveable_directions.size() > 1:
        moveable_directions.erase(current_dir)

    # So now we have our moveable positions, get one randomly from the array
    var random_dir = moveable_directions[randi() % moveable_directions.size()]

    # Then return that position as a world vector
    return tilemap.map_to_world(dir_tile_positions[random_dir])

# Returns the ID of the direction the ghost last headed in
func get_current_direction_id():
    # The movement between the ghosts  previous_position and current_position
    var last_movement_vector =  previous_position - get_pos()

    # If the difference between the previous and current position on the
    # x axis is lower than 0 the ghost must have moved left so return that
    if last_movement_vector.x < 0:
        return DIRECTIONS.LEFT

    # And similarly for the other directions
    if last_movement_vector.x > 0:
        return DIRECTIONS.RIGHT
    if last_movement_vector.y < 0:
        return DIRECTIONS.UP
    if last_movement_vector.y > 0:
        return DIRECTIONS.DOWN

    # If we have no movement just return -1 as an error
    return -1

