class VerticalTile < Tile
  def initialize
		@paths = []
		@paths << Path.new(lambda {|s| [25, Tile.height-s]}, Tile.height, [25,0]) #entrance from north
		@paths << Path.new(lambda {|s| [35, s]}, Tile.height, [35,Tile.height]) #entrance from south

		@start_positions = []
		@paths.each do |p|
			distance = 1 + Car.length
			while distance <= p.length
				@start_positions << {:distance => distance, :path => p}
				distance += Car.length + 2
			end
		end
  end
end
