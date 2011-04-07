#done and tested
class CrossTile < Tile
  def initialize
    @paths = []
    
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

    #copy of vertical
    ns = LockablePath.new(lambda {|s| [25, Tile.height-s]}, Tile.height, [25,0]) #entrance from north
    sn = LockablePath.new(lambda {|s| [35, s]}, Tile.height, [35,Tile.height]) #entrance from south
		@paths << ns
		@paths << sn

    all = [ws, sw, es, se, we, ew, nw, wn, ne, en, ns, sn]
    ws.crossing_paths = [ws, es, ns]
    sw.crossing_paths = all - [en, ws, sn]
    es.crossing_paths = all - [ew, nw, se]
    se.crossing_paths = [se, we, ne]
    nw.crossing_paths = [nw, sw, ew]
    wn.crossing_paths = all - [we, sw, nw]
    ne.crossing_paths = all - [ns, en, ws]
    en.crossing_paths = [en, ew, wn]
    we.crossing_paths = all - [ws, wn, ew, en, nw]
    ew.crossing_paths = all - [es, en, we, es, sw]
    ns.crossing_paths = all - [ne, nw, sn, sw, wn]
    sn.crossing_paths = all - [se, sw, ns, ws, ne]

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
