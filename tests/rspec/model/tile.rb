require "trafficsim"

describe Tile, "#paths" do
	it "returns Paths" do
		t = Tile.new
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

describe Tile, "#start_pos" do
	it "returns starting positions when available" do
		t = Tile.new
		p = t.start_pos
		p[:distance].should == 1 + Car.length
		p[:path].should be_an_instance_of Path
		9.times{ t.start_pos.should_not be_nil }
		t.start_pos.should be_nil
	end
end

describe Tile, ".width" do
	it "returns 60" do
		Tile.width.should == 60
	end
end
