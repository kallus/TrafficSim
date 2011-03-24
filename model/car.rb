class Car
  attr :angle
  attr :current_path
  attr :grid_pos
  attr :dead
  attr :speed
  attr_reader :distance
  attr_reader :number
  @@serial_number = 1

  def initialize(path, distance, grid_pos, tile_grid)
    @number = @@serial_number
    @@serial_number += 1

    @dead = false
    @angle = 0
    @current_path = path
    @distance = distance
    @grid_pos = grid_pos
    @tile_grid = tile_grid
    @grid_size = [@tile_grid[0].length,@tile_grid.length]

    @speed = 0
    @acceleration = 0
    @jerk = 0

    @target_jerk = 0.2
    @target_speed = 8 + 4 * rand
    @max_acceleration = 1
    @target_distance = 20

    path.add_car!(self)
  end

  def pos
    pos = current_path.point(@distance)
    local_to_global(pos)
  end

  def update_acceleration!
    if distance_to_next_car > -1 and distance_to_next_car < @target_distance
      @acceleration = -@max_acceleration
    elsif speed < @target_speed
      @acceleration = @max_acceleration
    elsif speed > @target_speed
      @acceleration = -@max_acceleration
    else
      @acceleration = 0
    end
  end

  def step!(time) #seconds
    update_acceleration!
    @speed += @acceleration * time
    @distance += speed * time
    
    if @distance > current_path.length then
      current_path.delete_car!(self)
      @distance -= current_path.length
      temporary_path = next_path
      @prev_grid_pos = grid_pos
      @grid_pos = next_grid_pos
      @prev_path = current_path
      @current_path = temporary_path
      if current_path
        current_path.add_car!(self)
      else
        @dead = true
      end
    end
  end

  def tail
    t_dist = @distance-Car.length
    if t_dist < 0 #dont let this happen when prev_path is not set
      local_to_global(@prev_path.point(@prev_path.length+t_dist),@prev_grid_pos)
    else
      local_to_global(current_path.point(t_dist))
    end
  end

  class << self
    def length
      7
    end

    def width
      5
    end
  end

  def next_grid_pos
    [grid_pos[0] + current_path.end_direction[0],
     grid_pos[1] + current_path.end_direction[1]]
  end

  def next_path
    n = next_grid_pos
    if n[0] >= @grid_size[0] || n[1] >= @grid_size[1] || n[0] < 0 || n[1] < 0 then
      puts "next grid position out of bounds"
      return false
    end

    paths = @tile_grid[n[1]][n[0]].paths(current_path.next_entrance_point)
    if paths.empty? then
      puts "found no next path"
      return false
    end

    return paths[rand(paths.length)]
  end

  def distance_to_next_car
    inf = -1  # should come up with something better
    if current_path == nil
      return inf 
    end

    cars_on_this_path = current_path.cars
    if cars_on_this_path.last == self # no cars in front, on this tile
      return inf unless next_path
      cars_on_next_path = next_path.cars
      return inf unless cars_on_next_path
      return inf unless cars_on_next_path.first
      return (cars_on_next_path.first.distance + (current_path.length - @distance))
    else
      index_of_this_car = cars_on_this_path.index(self)
      return (cars_on_this_path[index_of_this_car+1].distance - @distance)
    end
  end

  def next_car_number
    if current_path == nil
      return -1
    end

    cars_on_this_path = current_path.cars
    if cars_on_this_path.last == self
      return -1 unless next_path
      cars_on_next_path = next_path.cars
      return -1 unless cars_on_next_path
      return -1 unless cars_on_next_path.first
      return cars_on_next_path.first.number
    else
      index_of_this_car = cars_on_this_path.index(self)
      return cars_on_this_path[index_of_this_car+1].number
    end
  end

  def tile
    @tile_grid[@grid_pos[1]][@grid_pos[0]]
  end
		
  private
  def local_to_global(pos, gpos = grid_pos)
    [pos[0] + gpos[0] * Tile.width,
     pos[1] + gpos[1] * Tile.height]
  end
end
