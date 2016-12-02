extends Sprite

# References
var tilemap

# Movement
var speed = 100 # Movement Speed
var target_pos  # The position

var current_dir = "left" # Current direction
var target_dir  = "left" # Last direction pressed

func set_tilemap(_tilemap):
    tilemap = _tilemap

func set_tilemap_position(pos):
    set_pos(pos)
    target_pos = get_pos()

func _process(delta):
    handle_input()
    handle_movement(delta)

# Checks the projects relevant input map actions and sets the target_dir based
# On the last pressed directional key
func handle_input():
    if Input.is_action_pressed("ui_left"):
        target_dir = "left"
    if Input.is_action_pressed("ui_right"):
        target_dir = "right"
    if Input.is_action_pressed("ui_up"):
        target_dir = "up"
    if Input.is_action_pressed("ui_down"):
        target_dir = "down"

# Handles the movement of pacman
func handle_movement(delta):
    # If the distance_to our target position is under a pixel we have arrived
    # We set out position to the target_pos so that we're exactly where we want to be,
    # this way we can change direction and be in precisely line with the tiles.
    # We also tell the tilemap we want to eat the dot at this position, the tilemap will
    # check if there is one or not and handle the request
    if(get_pos().distance_to(target_pos) < 1):
        set_pos(target_pos)
        get_new_target_pos()
        tilemap.eat_dot_at(tilemap.world_to_map(get_pos()))

    # If we're not at our direction yet (or we just got a new one) move towards it
    var move_direction = (target_pos - get_pos()).normalized()
    set_pos(get_pos() + (move_direction * speed * delta))

# Gets the next tiles position to move to
# Called whenever pacman hits a tile
func get_new_target_pos():
    # First check to see if the target direction can be moved to
    # from this new tile, if it can set that as the new current direction.
    var target = get_vector_for_direction(target_dir)
    if(!tilemap.tile_at_pos_is_wall(target)):
        target_pos  = tilemap.map_to_world(target)
        current_dir = target_dir
        return
    # If we can't move in our target direction because there is a wall there
    # we'll keep moving in the current direction we're moving, unless there is
    # a wall there as well
    target = get_vector_for_direction(current_dir)
    if(!tilemap.tile_at_pos_is_wall(target)):
        target_pos = tilemap.map_to_world(target)
        return
    # If there is a wall there just stop and think about what you've done.
    target_pos = get_pos()

# Returns the tile position of the tile in the direction given
func get_vector_for_direction(d):
    var t_pos = tilemap.world_to_map(get_pos())
    if(d == "left"):
        return Vector2(t_pos.x - 1, t_pos.y)
    if(d == "right"):
        return Vector2(t_pos.x + 1, t_pos.y)
    if(d == "up"):
        return Vector2(t_pos.x, t_pos.y - 1)
    if(d == "down"):
        return Vector2(t_pos.x, t_pos.y + 1)
