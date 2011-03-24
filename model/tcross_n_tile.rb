#done and tested
class TcrossNTile < Crossing
  def initialize
    @paths = []

#copy of SW turn
    entrance_west = lambda do |s|
      s = s.to_f
      r = 5.0
      if s < 20 then [s, 25]
      elsif s < 20 + r/2*Math::PI then
        [20+r*Math.sin((s-20)/r),20+r*Math.cos((s-20)/r)]
      else [25, 40+r/2*Math::PI-s]
      end
    end
    entrance_south = lambda do |s|
      s = s.to_f
      r = 15.0
      if s < 20 then [35, s]
      elsif s < 20 + r/2*Math::PI then
        [20+r*Math.cos((s-20)/r), 20+r*Math.sin((s-20)/r)]
      else [40+r/2*Math::PI-s, 35]
      end
    end
    @paths << Path.new(entrance_west, 40+2.5*Math::PI, [25,0])
    @paths << Path.new(entrance_south, 40+7.5*Math::PI, [0,35])

#copy of SE turn
    entrance_east = lambda do |s|
      s = s.to_f
      r = 15.0
      if s < 20 then [Tile.width-s, 35]
      elsif s < 20 + r/2*Math::PI then
        [40-r*Math.sin((s-20)/r),20+r*Math.cos((s-20)/r)]
      else [25, 40+r/2*Math::PI-s]
      end
    end
    entrance_south = lambda do |s|
      s = s.to_f
      r = 5.0
      if s < 20 then [35, s]
      elsif s < 20 + r/2*Math::PI then
        [40-r*Math.cos((s-20)/r), 20+r*Math.sin((s-20)/r)]
      else [s+20-r/2*Math::PI, 25]
      end
    end
    @paths << Path.new(entrance_east, 40+7.5*Math::PI, [25,0])
    @paths << Path.new(entrance_south, 40+2.5*Math::PI, [Tile.width,25])

#copy of horizontal
    @paths << Path.new(lambda {|s| [s, 25]}, Tile.width, [Tile.width,25]) #entrance from west
    @paths << Path.new(lambda {|s| [Tile.width-s, 35]}, Tile.width, [0,35]) #entrance from east

    
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
