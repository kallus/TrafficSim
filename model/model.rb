class Model
	attr :cars
	attr :tile_grid
  attr_reader :time

  def initialize
    @time = 0
		@cars = []
		@tile_grid = []
    @tile_grid << [HorizontalTile.new, HorizontalTile.new, TurnSwTile.new]
    @tile_grid.each_with_index do |tiles, y|
      tiles.each_with_index do |tile, x|
        while true do
          start = tile.start_pos
          break unless start
          @cars << Car.new(start[:path], start[:distance], [x,y], tile_grid)
        end
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
