class Car
  attr :angle
  attr :current_path
  attr :grid_pos
  attr :dead
  attr :speed
  attr_reader :distance
  attr_reader :number
  attr_accessor :target_speed
  @@serial_number = 1

  def initialize(path, distance, grid_pos, tile_grid)
    @number = @@serial_number
    @@serial_number += 1

    @dead = false
    @angle = 0
    @current_path = path
    @next_path = nil
    @distance = distance
    @grid_pos = grid_pos
    @tile_grid = tile_grid
    @grid_size = [@tile_grid[0].length,@tile_grid.length]

    @speed = 0
    @acceleration = 0

    @target_speed = 8 + 4 * rand
    @max_acceleration = 1
    @target_distance = 30

    try_lock_paths! path
    path.add_car!(self)
  end

  def pos
    pos = current_path.point(@distance)
    local_to_global(pos)
  end

  def update_acceleration!
    dtno = distance_to_next_obstruction
    if dtno < @target_distance
      diff = @target_distance - dtno
      @acceleration = (diff/@target_distance*4) ** 2 * -@max_acceleration - @max_acceleration
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
    if speed < 0
      #puts "#{@number} stopped from going backwards"
      @speed = 0
    end

    new_distance = @distance + speed * time
    if new_distance > current_path.length and try_lock_paths! next_path then
      puts "removing #{@number} from #{current_path}"
      current_path.delete_car!(self)
      unlock_paths!
      @distance = new_distance - current_path.length
      @prev_grid_pos = grid_pos
      @grid_pos = next_grid_pos
      @prev_path = current_path
      @current_path = next_path
      @next_path = nil
      if current_path
        puts "Adding #{@number} to #{current_path}"
        current_path.add_car!(self)
      else
        puts "#{@number} dead"
        @dead = true
      end
    else
      @distance = [new_distance, current_path.length].min
    end
  end

  def unlock_paths!
    if current_path.kind_of? LockablePath
      current_path.crossing_paths.each do |path|
        path.release(self) if path.has_lock?(self)
      end
    end
  end

  def try_lock_paths!(n_path)
    if n_path.kind_of? LockablePath
      all_available = true
      n_path.crossing_paths.each do |path|
        puts "#{@number} looking at #{path}"
        if path.is_locked? and not path.has_lock?(self)
          all_available = false
        end
      end

      if all_available
        n_path.crossing_paths.each do |path|
          path.try_lock(self)
        end
        @waiting_for_path = nil
      else
        puts "#{@number} emergency brake"
        @speed = 0
        @acceleration = 0
        @waiting_for_path = n_path
        return false
      end
    end
    return true
  end

  def has_locks_for_path?(n_path)
    if n_path.kind_of? LockablePath
      n_path.crossing_paths.each do |path|
        if not path.has_lock?(self)
          return false
        end
      end
    end
    return true
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

  def next_tile
    ngs = next_grid_pos
    return @tile_grid[ngs[1]][ngs[0]]
  end

  def current_tile
    return @tile_grid[grid_pos[1]][grid_pos[0]]
  end

  def next_grid_pos
    [grid_pos[0] + current_path.end_direction[0],
     grid_pos[1] + current_path.end_direction[1]]
  end

  def next_path
    if @next_path != nil
      return @next_path
    end

    n = next_grid_pos
    if n[0] >= @grid_size[0] || n[1] >= @grid_size[1] || n[0] < 0 || n[1] < 0 then
      puts "next grid position out of bounds"
      puts grid_pos
      puts next_grid_pos
      return false
    end

    paths = @tile_grid[n[1]][n[0]].paths(current_path.next_entrance_point)
    if paths.empty? then
      puts "found no next path"
      return false
    end

    @next_path = paths[rand(paths.length)]
    return @next_path
  end

  def distance_to_next_obstruction
    inf = 1000  # should come up with something better

    cars_on_this_path = current_path.cars
    if cars_on_this_path.last == self # no cars in front, on this tile
      return inf unless next_path
      if next_path.kind_of?(LockablePath)
        if next_path.is_locked? and not has_locks_for_path?(next_path)
          return (current_path.length - @distance)
        end
      end

      cars_on_next_path = next_path.cars
      return inf unless cars_on_next_path
      return inf unless cars_on_next_path.first
      return (cars_on_next_path.first.distance - Car.length + (current_path.length - @distance))
    else
      index_of_this_car = cars_on_this_path.index(self)
      return (cars_on_this_path[index_of_this_car+1].distance - Car.length - @distance)
    end
  end

  def next_car_number
    cars_on_this_path = current_path.cars
    if cars_on_this_path.last == self
      return -1 unless next_path
      cars_on_next_path = next_path.cars
      return -1 unless cars_on_next_path
      return -1 unless cars_on_next_path.first
      return cars_on_next_path.first.number
    else
      index_of_this_car = cars_on_this_path.index(self)
      if index_of_this_car == nil
        raise "#{@number} not found on #{@current_path}"
      end
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
