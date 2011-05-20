class Car
  attr :angle
  attr :current_path
  attr :grid_pos
  attr :dead
  attr :speed
  attr :speed_history
  attr :lifetime
  attr_reader :distance
  attr_reader :number
  attr_reader :nhist
  attr_accessor :target_speed
  @@serial_number = 1
  @@time_lag = 2.0   # seconds

  def initialize(path, distance, grid_pos, model, targets)
    @number = @@serial_number
    @@serial_number += 1

    @lifetime = 0.0
    @dead = false
    @angle = 0
    @current_path = path
    @next_path = nil
    @distance = distance
    @grid_pos = grid_pos
    @model = model
    @targets = targets
    @tile_grid = model.tile_grid
    @grid_size = [@tile_grid[0].length,@tile_grid.length]
    @nhist = @@time_lag / model.step_length
    if @nhist.floor != @nhist.ceil
      raise "@@time_lag / model.step_length must be a natural number"
    end
    @speed_history = Array.new(@nhist, 0)

    @route = []
    if @targets != nil and @targets.length > 0
      @route = @model.graph.best_first(path, @targets[rand(@targets.length)], {})
      if @route.length == 0
        puts "couldn't find route!"
      end
      @route.shift
#      puts "--- found route for " + @number.to_s
#      puts @route.collect { |e| e.inspect }.join(", ")
#      puts "---"
    end

    @speed = 0
    @acceleration = 0

    @target_speed = 8 + 2 * rand
    @max_acceleration = 1
    @target_distance = 30

    try_lock_paths! path
    path.add_car!(self)
  end

  def rand_car?
    @targets.empty?
  end

  def pos
    pos = current_path.point(@distance)
    local_to_global(pos)
  end

  def update_speed_history!
    @speed_history.shift
    @speed_history << @speed
  end

  def update_acceleration2!
    dtno = distance_to_next_obstruction
    dtnc = distance_to_next_car
    lambda = 0.22
    following_distance = Car.length*5

    if dtno > following_distance
      @acceleration = @max_acceleration
    elsif (dtnc >= 0 and dtnc <= dtno)  # next obstacle is a car
      nc = next_car
      @acceleration = lambda*(nc.speed_history.first - speed_history.first)
    else  # any other obstacle has speed zero
      @acceleration = lambda*(0 - speed_history.first)
    end
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
    @lifetime += time

    update_speed_history!
    update_acceleration2!
    @speed += @acceleration * time
    if speed < 0
      #puts "#{@number} stopped from going backwards"
      @speed = 0
    end

    @speed = @target_speed if @speed > @target_speed

    new_distance = @distance + speed * time
    if new_distance > current_path.length and try_lock_paths! next_path then
#      puts "removing #{@number} from #{current_path}" if $debug
      current_path.delete_car!(self)
      unlock_paths!
      @distance = new_distance - current_path.length
      @prev_grid_pos = grid_pos
      @grid_pos = next_grid_pos
      @prev_path = current_path
      @current_path = next_path
      @next_path = nil
      if current_path
#        puts "Adding #{@number} to #{current_path}" if $debug
        current_path.add_car!(self)
      else
        puts "#{@number} dead" if $debug
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
#        puts "#{@number} looking at #{path}" if $debug
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
        if @speed > 0 or @acceleration > 0
#          puts "#{@number} emergency brake" if $debug
          @speed = 0
          @acceleration = 0
        end
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

    if not @route.empty?
      @next_path = @route.shift
      return @next_path
    end

    n = next_grid_pos
    if n[0] >= @grid_size[0] || n[1] >= @grid_size[1] || n[0] < 0 || n[1] < 0 then
#      puts "next grid position out of bounds" if $debug
#      puts grid_pos if $debug
#      puts next_grid_pos if $debug
      return false
    end

    paths = @tile_grid[n[1]][n[0]].paths(current_path.next_entrance_point)
    if paths.empty? then
      puts "found no next path" if $debug
      return false
    end

    # dont let random cars drive out of map
    while true
      @next_path = paths[rand(paths.length)]
      next_next_grid_pos = [n[0] + @next_path.end_direction[0], n[1] + @next_path.end_direction[1]]
      nn = next_next_grid_pos
      unless nn[0] >= @grid_size[0] || nn[1] >= @grid_size[1] || nn[0] < 0 || nn[1] < 0 then
        break
      end
    end
    return @next_path
  end

  def next_car
    cars_on_this_path = current_path.cars
    if cars_on_this_path.last == self  # no cars in front, on this tile
      return nil unless next_path
      cars_on_next_path = next_path.cars
      return nil unless cars_on_next_path
      return nil unless cars_on_next_path.first
      return cars_on_next_path.first
    else
      index_of_this_car = cars_on_this_path.index(self)
      return cars_on_this_path[index_of_this_car+1]
    end
  end

  def distance_to_next_car
    nc = next_car
    return -1 unless nc
    if nc.current_path == current_path
      return (nc.distance - Car.length - @distance)
    else
      return (nc.distance - Car.length - (current_path.length - @distance))
    end

    # inf = -1   # ugly hack
    # cars_on_this_path = current_path.cars
    # if cars_on_this_path.last == self  # no cars in front, on this tile
    #   return inf unless next_path
    #   cars_on_next_path = next_path.cars
    #   return inf unless cars_on_next_path
    #   return inf unless cars_on_next_path.first
    #   return (cars_on_next_path[index_of_this_car+1].distance - Car.length + (current_path.length - @distance))
    # else
    #   index_of_this_car = cars_on_this_path.index(self)
    #   return (cars_on_this_path[index_of_this_car+1].distance - Car.length - @distance)
    # end
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
