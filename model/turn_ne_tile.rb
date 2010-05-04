class TurnNeTile < Tile
  def initialize
		@paths = []
    entrance_east = lambda do |s|
      s = s.to_f
      r = 5.0
      if s < 20 then [Tile.width-s, 35]
      elsif s < 20 + r/2*Math::PI then
        [40-r*Math.sin((s-20)/r),40-r*Math.cos((s-20)/r)]
      else [35, 20+s-r/2*Math::PI]
      end
    end
    entrance_north = lambda do |s|
      s = s.to_f
      r = 15.0
      if s < 20 then [25, Tile.height-s]
      elsif s < 20 + r/2*Math::PI then
        [40-r*Math.cos((s-20)/r), 40-r*Math.sin((s-20)/r)]
      else [20+s-r/2*Math::PI, 25]
      end
    end
		@paths << Path.new(entrance_east, 40+2.5*Math::PI, [35,Tile.height])
		@paths << Path.new(entrance_north, 40+7.5*Math::PI, [Tile.width,25])

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
