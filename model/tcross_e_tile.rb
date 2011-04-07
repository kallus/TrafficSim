#done and tested
class TcrossETile < Tile
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

    #copy of NW turn
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

    #copy of vertical
    ns = LockablePath.new(lambda {|s| [25, Tile.height-s]}, Tile.height, [25,0]) #entrance from north
    sn = LockablePath.new(lambda {|s| [35, s]}, Tile.height, [35,Tile.height]) #entrance from south
		@paths << ns
		@paths << sn

    ws.crossing_paths = [ws, ns]
    sw.crossing_paths = [sw, ns, wn, nw]
    wn.crossing_paths = [wn, ns, sn, sw]
    nw.crossing_paths = [nw, sw]
    ns.crossing_paths = [ns, sw, wn, ws]
    sn.crossing_paths = [sn, wn]

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
