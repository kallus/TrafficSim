#done and tested
class TcrossSTile < Tile
  def initialize
    @paths = []
    #copy of NE tile
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
    en = LockablePath.new(entrance_east, 40+2.5*Math::PI, [35,Tile.height])
    ne = LockablePath.new(entrance_north, 40+7.5*Math::PI, [Tile.width,25])
    @paths << en
    @paths << ne
    
    #copy of NW tile
    entrance_west = lambda do |s|
      s = s.to_f
      r = 15.0
      if s < 20 then [s, 25]
      elsif s < 20 + r/2*Math::PI then
        [20+r*Math.sin((s-20)/r),40-r*Math.cos((s-20)/r)]
      else [35, 20-r/2*Math::PI+s]
      end
    end
    entrance_north = lambda do |s|
      s = s.to_f
      r = 5.0
      if s < 20 then [25, Tile.height-s]
      elsif s < 20 + r/2*Math::PI then
        [20+r*Math.cos((s-20)/r), 40-r*Math.sin((s-20)/r)]
      else [40+r/2*Math::PI-s, 35]
      end
    end
    wn = LockablePath.new(entrance_west, 40+7.5*Math::PI, [35,Tile.width])
    nw = LockablePath.new(entrance_north, 40+2.5*Math::PI, [0,35])
    @paths << wn
    @paths << nw
    
    #copy of horizontal
    we = LockablePath.new(lambda {|s| [s, 25]}, Tile.width, [Tile.width,25]) #entrance from west
    ew = LockablePath.new(lambda {|s| [Tile.width-s, 35]}, Tile.width, [0,35]) #entrance from east
    @paths << we
    @paths << ew
    
    en.crossing_paths = [en, wn]
    ne.crossing_paths = [ne, wn, we, ew]
    wn.crossing_paths = [wn, en, we, ew]
    nw.crossing_paths = [nw, ew]
    we.crossing_paths = [we, ne]
    ew.crossing_paths = [ew, ne, wn, en]
    
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
