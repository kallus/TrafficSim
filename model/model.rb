class Model
  attr :cars
  attr_accessor :tile_grid
  attr_reader :time

  def initialize
    @time = 0
    @cars = []
    @tile_grid = []
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
    @tile_grid << [TurnSeTile.new, TcrossNTile.new, TurnSwTile.new]
    @tile_grid << [VerticalTile.new, VerticalTile.new, VerticalTile.new]
    @tile_grid << [TurnNeTile.new, TcrossSTile.new, TurnNwTile.new]
    @tile_grid.reverse!
    # add one car to each tile
    @tile_grid.each_with_index do |tiles, y|
      tiles.each_with_index do |tile, x|
        start = tile.start_pos
        @cars << Car.new(start[:path], start[:distance], [x,y], tile_grid)
      end
    end
  end

  def step!(step_length) #seconds
    cars.each do |c|
      c.step!(step_length)
    end
    cars.delete_if{|c| c.dead}
    @time += step_length
  end
end
