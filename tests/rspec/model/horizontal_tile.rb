require "trafficsim"

describe HorizontalTile, "#paths" do
	it "returns Paths" do
		t = HorizontalTile.new
		paths = t.paths([Tile.width, 35]) #east
		paths.length.should == 1
		paths = t.paths([0, 25]) #west
		paths.length.should == 1
		paths = t.paths([25, Tile.height]) #north
		paths.length.should == 0
		paths = t.paths([35, 0]) #south
		paths.length.should == 0
	end
end

describe HorizontalTile, "#start_pos" do
	it "returns starting positions when available" do
		t = HorizontalTile.new
		10.times do
      p = t.start_pos
      p.should_not be_nil
      p[:distance].should be_integer
      p[:path].should be_an_instance_of Path
    end
		t.start_pos.should be_nil
	end
end
