class HorizontalTile < Tile
  def initialize
		@paths = []
		@paths << Path.new(lambda {|s| [s, 25]}, Tile.width) #entrance from west
		@paths << Path.new(lambda {|s| [Tile.width - s, 35]}, Tile.width) #entrance from east

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
