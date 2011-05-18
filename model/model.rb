class Model
  attr_accessor :cars
  attr_accessor :tile_grid
  attr_accessor :time
  attr_accessor :step_length  # step length in seconds
  attr_reader :graph

  def initialize(step_length)
    @time = 0
    @cars = []
    @tile_grid = []
    @car_creators = []
    @graph = nil
    @step_length = step_length
  end

  def init_boring_town
    tile_grid << [TurnSeTile.new, TcrossNTile.new, TurnSwTile.new]
    tile_grid << [TurnNeTile.new, TcrossSTile.new, TurnNwTile.new]
    tile_grid.reverse!
    start = tile_grid[0][0].start_pos
    car1 = Car.new(start[:path], start[:distance], [0, 0], self)
    car1.target_speed = 16
    @cars << car1
    start = tile_grid[0][1].start_pos
    car2 = Car.new(start[:path], start[:distance], [1, 0], self)
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

    cars_per_second = 1
    number_of_cars = 10
    @car_creators << CarCreator.new(@cars, self, [0, height-1], nw.paths([0, 25]), cars_per_second, number_of_cars)
    @car_creators << CarCreator.new(@cars, self, [width-1, height-1], ne.paths([Tile.width, 35]), cars_per_second, number_of_cars)
    @car_creators << CarCreator.new(@cars, self, [0, 0], sw.paths([0, 25]), cars_per_second, number_of_cars)
    @car_creators << CarCreator.new(@cars, self, [width-1, 0], se.paths([Tile.width, 35]), cars_per_second, number_of_cars)
  end
  
  def out_paths(origin)
    width = @tile_grid.first.length
    height = @tile_grid.length
    out_nw = @tile_grid.last[0].all_paths.select{|p| p.end_direction == [-1, 0]}
    out_ne = @tile_grid.last[width-1].all_paths.select{|p| p.end_direction == [1, 0]}
    out_sw = @tile_grid.first[0].all_paths.select{|p| p.end_direction == [-1, 0]}
    out_se = @tile_grid.first[width-1].all_paths.select{|p| p.end_direction == [1, 0]}
    all = out_nw + out_ne + out_sw + out_se
    case origin
    when [0, height-1]
      all - out_nw
    when [width-1, height-1]
      all - out_ne
    when [0, 0]
      all - out_sw
    when [width-1, 0]
      all - out_se
    end
  end

  def target_paths
    width = @tile_grid.first.length
    height = @tile_grid.length
    target_paths = []
    target_paths << @tile_grid[height/4 + (height/4) % 2][width/4 + (width/4) % 2].all_paths.first
    target_paths << @tile_grid[3*height/4 + (3*height/4) % 2][width/4 + (width/4) % 2].all_paths.first
    target_paths << @tile_grid[height/4 + (height/4) % 2][3*width/4 + (3*width/4) % 2].all_paths.first
    target_paths << @tile_grid[3*height/4 + (3*height/4) % 2][3*width/4 + (3*width/4) % 2].all_paths.first
    target_paths
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

  def step!
    cars.each do |c|
      c.step!(@step_length) unless c.dead
    end

    @car_creators.each do |cc|
      cc.step!(@step_length)
    end

#    cars.delete_if{|c| c.dead}
    @time += @step_length
  end

  private
  def next_tile(path, x, y)
    nx = x + path.end_direction[0]
    ny = y + path.end_direction[1]
    if nx >= @tile_grid[0].length or ny >= @tile_grid.length or nx < 0 or ny < 0
      puts "next grid position out of bounds" if $debug
      return nil
    end
    return @tile_grid[ny][nx]
  end
end
