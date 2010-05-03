#done not tested
class TurnSeTile < Tile
  def initialize
		@paths = []
    entrance_east = lambda do |s|
      if s < 20 then [Tile.width-s, 35]
      elsif s < 20 + 7.5*Math::PI then [Tile.width-20-15*Math.sin((s-20.0)/5),35 - 15*Math.sin((s-20.0)/5)]
      else [25, 40 - s + 7.5*Math::PI]
      end
    end
    entrance_south = lambda do |s|
      if s < 20 then [35, s]
      elsif s < 20 + 2.5*Math::PI then [35+5*Math.sin((s-20.0)/5), 20+5*Math.sin((s-20.0)/5)]
      else [40 - s + 2.5*Math::PI, 25]
      end
    end
		@paths << Path.new(entrance_east, 40+7.5*Math::PI)
		@paths << Path.new(entrance_south, 40+2.5*Math::PI)

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
