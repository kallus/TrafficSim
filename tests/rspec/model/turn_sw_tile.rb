require "trafficsim"

describe TurnSwTile, "#paths" do
  it "should return a reasonable west path" do
    t = TurnSwTile.new
    w = t.paths([0,25])
    w.length.should == 1
    w = w.first
    (1..w.length.floor).to_a.each do |i|
#puts "#{i}: (#{w.point(i)[0]},#{w.point(i)[1]})"
      (w.point(i)[0] >= w.point(i-1)[0]).should be_true
      (w.point(i)[1] <= w.point(i-1)[1]).should be_true
      (w.point(i) == w.point(i-1)).should be_false
      w.point(i).each{|p| (p >= 0 && p <= Tile.width).should be_true}
    end
  end

  it "should return a reasonable south path" do
    t = TurnSwTile.new
    s = t.paths([35,0])
    s.length.should == 1
    s = s.first
    (1..s.length.floor).to_a.each do |i|
      (s.point(i)[0] <= s.point(i-1)[0]).should be_true
      (s.point(i)[1] >= s.point(i-1)[1]).should be_true
      (s.point(i) == s.point(i-1)).should be_false
      #puts "#{i}: (#{s.point(i)[0]},#{s.point(i)[1]})"
      s.point(i).each{|p| (p >= 0 && p <= Tile.width).should be_true}
    end
  end
end
