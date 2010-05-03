#done not tested
class TurnSwTile < Tile
  def initialize
		@paths = []
    entrance_east = lambda do |s|
      if s < 20 then [Tile.width-s, 35]
      elsif s < 20 + 2.5*Math::PI then [Tile.width-20-5*Math.sin((s-20.0)/5),35+5*Math.sin((s-20.0)/5)]
      else [35, 40-s + 2.5*Math::PI]
      end
    end
    entrance_north = lambda do |s|
      if s < 20 then [25, Tile.height-s]
      elsif s < 20 + 7.5*Math::PI then [25+15*Math.sin((s-20.0)/15), Tile.height-20-15*Math.sin((s-20.0)/15)]
      else [40 - s + 7.5*Math::PI, 35]
      end
    end
		@paths << Path.new(entrance_west, 40+2.5*Math::PI)
		@paths << Path.new(entrance_south, 40+7.5*Math::PI)

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
