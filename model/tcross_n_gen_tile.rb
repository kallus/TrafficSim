class TcrossNGenTile < Tile

  # should possibly get these from constructor
  SECONDS_BETWEEN_CARS = 15
  NUMBER_OF_CARS_TO_PRODUCE = 14

  def initialize
    @time_since_last_creation = SECONDS_BETWEEN_CARS  # create a car immediately
    @ncars_produced = 0
    @paths = []
    
    #copy of SW turn
    entrance_west = lambda do |s|
      s = s.to_f
      r = 5.0
      if s < 20 then [s, 25]
      elsif s < 20 + r/2*Math::PI then
        [20+r*Math.sin((s-20)/r),20+r*Math.cos((s-20)/r)]
      else [25, 40+r/2*Math::PI-s]
      end
    end
    entrance_south = lambda do |s|
      s = s.to_f
      r = 15.0
      if s < 20 then [35, s]
      elsif s < 20 + r/2*Math::PI then
        [20+r*Math.cos((s-20)/r), 20+r*Math.sin((s-20)/r)]
      else [40+r/2*Math::PI-s, 35]
      end
    end
    ws = LockablePath.new(entrance_west, 40+2.5*Math::PI, [25,0])
    @paths << ws

    #copy of SE turn
    entrance_east = lambda do |s|
      s = s.to_f
      r = 15.0
      if s < 20 then [Tile.width-s, 35]
      elsif s < 20 + r/2*Math::PI then
        [40-r*Math.sin((s-20)/r),20+r*Math.cos((s-20)/r)]
      else [25, 40+r/2*Math::PI-s]
      end
    end
    entrance_south = lambda do |s|
      s = s.to_f
      r = 5.0
      if s < 20 then [35, s]
      elsif s < 20 + r/2*Math::PI then
        [40-r*Math.cos((s-20)/r), 20+r*Math.sin((s-20)/r)]
      else [s+20-r/2*Math::PI, 25]
      end
    end
    es = LockablePath.new(entrance_east, 40+7.5*Math::PI, [25,0])
    se = LockablePath.new(entrance_south, 40+2.5*Math::PI, [Tile.width,25])
    @paths << es
    @paths << se

    #copy of horizontal
    we = LockablePath.new(lambda {|s| [s, 25]}, Tile.width, [Tile.width,25]) #entrance from west
    @paths << we

    ws.crossing_paths = [ws, es]
    es.crossing_paths = [es, we]
    se.crossing_paths = [se, we]
    we.crossing_paths = [we, es, se]

    @start_positions = []
    @paths.each do |p|
      distance = 1 + Car.length
      while distance <= p.length
        @start_positions << {:distance => distance, :path => p}
        distance += Car.length + 2
      end
    end
  end

  def step!(time, model)  # step length is in seconds
    return if @ncars_produced >= NUMBER_OF_CARS_TO_PRODUCE
    start = @start_positions.first
    @time_since_last_creation = @time_since_last_creation + time
    if @time_since_last_creation >= SECONDS_BETWEEN_CARS and crossing_is_clear?(start)
      # time to add a new car

      # find our x, y position
      x = nil
      y = nil
      model.tile_grid.each_with_index do |tiles, ty|
        y = ty
        x = tiles.index(self)
        break if x != nil
      end

      if x == nil or y == nil
        raise "Couldn't find this tile in the model's tile grid."
      end

      model.cars << Car.new(start[:path], start[:distance], [x, y], model.tile_grid)
      @time_since_last_creation = 0
      @ncars_produced = @ncars_produced + 1
    end
  end

  private
  def crossing_is_clear?(start)  # should probably not be an argument
    path = start[:path]
    return false if path.is_locked?
    path.crossing_paths.each do |p|
      return false if p.is_locked?
    end
  end
end
