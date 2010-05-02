class Model
	attr :cars
	attr :tile_grid

  def initialize
		@cars = []
		@tile_grid = []
    @tile_grid << [Tile.new, Tile.new, Tile.new]
    @tile_grid.each_with_index do |tiles, y|
      tiles.each_with_index do |tile, x|
        start = tile.start_pos
        @cars << Car.new(start[:path], start[:distance], [x,y])
      end
    end
  end

	def step!
	end
end
