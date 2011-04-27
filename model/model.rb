class Model
  attr_accessor :cars
  attr_accessor :tile_grid
  attr_reader :time

  def initialize
    @time = 0
    @cars = []
    @tile_grid = []
    @car_creators = []
  end

  def init_boring_town
    tile_grid << [TurnSeTile.new, TcrossNTile.new, TurnSwTile.new]
    tile_grid << [TurnNeTile.new, TcrossSTile.new, TurnNwTile.new]
    tile_grid.reverse!
    start = tile_grid[0][0].start_pos
    car1 = Car.new(start[:path], start[:distance], [0, 0], tile_grid)
    car1.target_speed = 16
    @cars << car1
    start = tile_grid[0][1].start_pos
    car2 = Car.new(start[:path], start[:distance], [1, 0], tile_grid)
    car2.target_speed = 6
    car2.try_lock_paths! car2.current_path
    @cars << car2
  end

  def init_small_town
    @tile_grid << [TcrossNGenTile.new, TcrossNTile.new, TurnSwTile.new]
    @tile_grid << [VerticalTile.new, VerticalTile.new, VerticalTile.new]
    @tile_grid << [TcrossWTile.new, CrossTile.new, TcrossETile.new]
    @tile_grid << [VerticalTile.new, VerticalTile.new, VerticalTile.new]
    @tile_grid << [TurnNeTile.new, TcrossSTile.new, TurnNwTile.new]
    @tile_grid.reverse!
    # add one car to each tile
    @tile_grid.each_with_index do |tiles, y|
      tiles.each_with_index do |tile, x|
        start = tile.start_pos
#        @cars << Car.new(start[:path], start[:distance], [x,y], tile_grid)
      end
    end
  end
  
  def init_town(width, height, connectivity)
    @tile_grid = MapGenerator.new_map(width, height, connectivity)
    width = @tile_grid.first.length
    height = @tile_grid.length
    nw = TcrossNTile.new
    @tile_grid.last[0] = nw
    ne = TcrossNTile.new
    @tile_grid.last[width-1] = ne
    sw = TcrossSTile.new
    @tile_grid.first[0] = sw
    se = TcrossSTile.new
    @tile_grid.first[width-1] = se

    @car_creators << CarCreator.new(@cars, @tile_grid, [0, height-1], nw.paths([0, 25]), 0.25, 10)
    @car_creators << CarCreator.new(@cars, @tile_grid, [width-1, height-1], ne.paths([Tile.width, 35]), 0.25, 10)
    @car_creators << CarCreator.new(@cars, @tile_grid, [0, 0], sw.paths([0, 25]), 0.25, 10)
    @car_creators << CarCreator.new(@cars, @tile_grid, [width-1, 0], se.paths([Tile.width, 35]), 0.25, 10)
  end

  def step!(step_length)  # step length in seconds
    cars.each do |c|
      c.step!(step_length)
    end

    @car_creators.each do |cc|
      cc.step!(step_length)
    end

    cars.delete_if{|c| c.dead}
    @time += step_length
  end
end
