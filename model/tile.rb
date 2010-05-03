class Tile
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

	def paths(entrance_point)
		@paths.select{|p| p.point(0) == entrance_point}
	end

  def start_pos
		@start_positions.delete_at(rand(@start_positions.length))
  end

  class << self
    def width
      60
    end

    def height
      60
    end
  end
end
