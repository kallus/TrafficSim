#done and tested
class TcrossNTile < Tile
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
    ws = LockablePath.new(entrance_west, 40+2.5*Math::PI, [25,0])
    sw = LockablePath.new(entrance_south, 40+7.5*Math::PI, [0,35])
    @paths << ws
    @paths << sw

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
    es = LockablePath.new(entrance_east, 40+7.5*Math::PI, [25,0])
    se = LockablePath.new(entrance_south, 40+2.5*Math::PI, [Tile.width,25])
    @paths << es
    @paths << se

#copy of horizontal
    we = LockablePath.new(lambda {|s| [s, 25]}, Tile.width, [Tile.width,25]) #entrance from west
    ew = LockablePath.new(lambda {|s| [Tile.width-s, 35]}, Tile.width, [0,35]) #entrance from east
    @paths << we
    @paths << ew

    sorter = lambda { |a, b| a.number <=> b.number }
    ws.crossing_paths = [ws].sort! &sorter
    sw.crossing_paths = [sw, es, we, ew].sort! &sorter
    es.crossing_paths = [es, sw, we, ew].sort! &sorter
    se.crossing_paths = [se, we].sort! &sorter
    we.crossing_paths = [we, es, sw, se].sort! &sorter
    ew.crossing_paths = [ew, sw].sort! &sorter

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
