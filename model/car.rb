class Car
  attr :angle
	attr :current_path
	attr :next_path
	attr :grid_pos
  attr_reader :dead

  def initialize(path, distance, grid_pos, tile_grid)
    @dead = false
    @angle = 0
		@current_path = path
		@distance = distance
		@grid_pos = grid_pos
		@tile_grid = tile_grid
		@dead = true unless choose_next_path!
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
			choose_next_grid_pos!
			current_path = next_path
			@dead = true unless choose_next_path!
		end
	end

  class << self
    def length
      10
    end

    def width
      5
    end
  end

	private
	def choose_next_path!
		end_point = current_path.point(current_path.length)
		trans = grid_transition(end_point)
		start_point = Array.new(end_point)
		start_point[0] = 0 if end_point[0] == Tile.width
		start_point[0] = Tile.width if end_point[0] == 0
		start_point[1] = 0 if end_point[1] == Tile.height
		start_point[1] = Tile.height if end_point[1] == 0
    next_row = grid_pos[1]+trans[1]
    next_column = grid_pos[0]+trans[0]
    return false if next_row >= @tile_grid.length || next_column >= @tile_grid[0].length
    return false if next_row < 0 || next_column < 0
		next_paths = @tile_grid[next_row][next_column].paths(start_point)
    return false if next_paths.empty?
    next_path = next_paths[rand(next_paths.length)]
	end

	def choose_next_grid_pos!
		end_point = current_path.point(current_path.length)
		grid_pos[0] += grid_transition(end_point)[0]
		grid_pos[1] += grid_transition(end_point)[1]
	end
		
	def local_to_global(pos)
		[
			pos[0] + grid_pos[0] * Tile.width,
			pos[1] + grid_pos[1] * Tile.height
		]
	end

	def grid_transition(end_point)
		trans = [0,0]
		trans[0] = 1 if end_point[0] == Tile.width
		trans[0] = -1 if end_point[0] == 0
		trans[1] = 1 if end_point[1] == Tile.height
		trans[1] = -1 if end_point[1] == 0
		trans
	end
end
