class Model
  attr_accessor :cars
  attr_accessor :tile_grid
  attr_reader :time
  attr_reader :graph

  def initialize
    @time = 0
    @cars = []
    @tile_grid = []
    @graph = nil
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
    @tile_grid.last[0] = TcrossNGenTile.new
    @tile_grid.first[@tile_grid.first.length-1] = TcrossSTile.new
  end

  def init_graph
    dg = Digraph.new
    @tile_grid.each_with_index do |tiles, y|
      tiles.each_with_index do |t, x|
        t.all_paths.each do |p|
          next_tile = next_tile(p, x, y)
          next if next_tile == nil
          next_paths = next_tile.paths(p.next_entrance_point)
          if next_paths.empty? then
            puts "init_graph: found no next path"
          else
            next_paths.each do |np|
              dg.add_edge!(p, np, 1)
            end
          end
        end
      end
    end
    @graph = dg
  end

  def step!(step_length)  # step length in seconds
    cars.each do |c|
      c.step!(step_length)
    end

    @tile_grid.each do |tiles|
      tiles.each do |t|
        t.step!(step_length, self)
      end
    end
    cars.delete_if{|c| c.dead}
    @time += step_length
  end

  private
  def next_tile(path, x, y)
    nx = x + path.end_direction[0]
    ny = y + path.end_direction[1]
    if nx >= @tile_grid[0].length or ny >= @tile_grid.length or nx < 0 or ny < 0
      puts "next grid position out of bounds"
      return nil
    end
    return @tile_grid[ny][nx]
  end
end
