class Model
	attr :cars
	attr :tile_grid
  attr_reader :time

  def initialize
    @time = 0
		@cars = []
		@tile_grid = []
    @tile_grid << [Tile.new, Tile.new, Tile.new]
    @tile_grid.each_with_index do |tiles, y|
      tiles.each_with_index do |tile, x|
        start = tile.start_pos
        @cars << Car.new(start[:path], start[:distance], [x,y], tile_grid)
				break
      end
    end
  end

	def step!(step_length) #seconds
		cars.each do |c|
			c.step!(step_length)
		end
    @time += step_length
	end
end
