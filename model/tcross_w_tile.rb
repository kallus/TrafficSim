#done and tested
class TcrossWTile < Tile
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

    #copy of vertical
    ns = LockablePath.new(lambda {|s| [25, Tile.height-s]}, Tile.height, [25,0]) #entrance from north
    sn = LockablePath.new(lambda {|s| [35, s]}, Tile.height, [35,Tile.height]) #entrance from south
    @paths << ns
    @paths << sn

    sorter = lambda { |a, b| a.number <=> b.number }
    es.crossing_paths = [es, sn, ns, ne, en].sort! &sorter
    se.crossing_paths = [se, ne, sn].sort! &sorter
    en.crossing_paths = [en, sn, es].sort! &sorter
    ne.crossing_paths = [ne, sn, es, se, ns].sort! &sorter
    ns.crossing_paths = [ns, es, ne].sort! &sorter
    sn.crossing_paths = [sn, ne, es, en, se].sort! &sorter

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
