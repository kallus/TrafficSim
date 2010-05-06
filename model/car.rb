class Car
  attr :angle
  attr :current_path
  attr :grid_pos
  attr :dead

  def initialize(path, distance, grid_pos, tile_grid)
    @dead = false
    @angle = 0
    @current_path = path
    @distance = distance
    @grid_pos = grid_pos
    @tile_grid = tile_grid
    @grid_size = [@tile_grid[0].length,@tile_grid.length]
  end

  def pos
    pos = @current_path.point(@distance)
    local_to_global(pos)
  end

  def speed #(m/s)
    10
  end

  def step!(time) #seconds
    @distance += speed * time
    
    if @distance > current_path.length then
      @distance -= current_path.length
      temporary_path = next_path
      @prev_grid_pos = @grid_pos
      @grid_pos = next_grid_pos
      @prev_path = @current_path
      @current_path = temporary_path
      @dead = true unless @current_path
    end
  end

  def tail
    t_dist = @distance-Car.length
    if t_dist < 0 #dont let this happen when prev_path is not set
      local_to_global(@prev_path.point(@prev_path.length+t_dist),@prev_grid_pos)
    else
      local_to_global(@current_path.point(t_dist))
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

  def tile
    @tile_grid[@grid_pos[1]][@grid_pos[0]]
  end
		
  private
  def local_to_global(pos, gpos = grid_pos)
    [pos[0] + gpos[0] * Tile.width,
     pos[1] + gpos[1] * Tile.height]
  end
end
