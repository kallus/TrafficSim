class Car
  attr :angle
	attr :current_path
	attr :next_path
	attr :grid_pos

  def initialize(path, distance, grid_pos)
    @angle = 0
		@current_path = path
		@distance = distance
		@grid_pos = grid_pos
		@next_path = path #for now
  end

	def pos
		pos = @current_path.point(@distance)
		pos[0] += grid_pos[0] * Tile.width
		pos[1] += grid_pos[1] * Tile.height
		pos
	end

  class << self
    def length
      10
    end

    def width
      5
    end
  end
end
