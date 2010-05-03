#not done nor tested
class TurnSwTile < Tile
  def initialize
		@paths = []
    entrance_west = lambda do |s|
      if s < 20 then [s, 25]
      elsif s < 20 + 2.5*Math::PI then [20 + 5*Math.sin((s-20.0)/5),25 - 5*Math.sin((s-20.0)/5)]
      else [25, 40 - s + 2.5*Math::PI]
      end
    end
    entrance_south = lambda do |s|
      if s < 20 then [35, s]
      elsif s < 20 + 7.5*Math::PI then [35-15*Math.sin((s-20.0)/15), 20+15*Math.sin((s-20.0)/15)]
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
