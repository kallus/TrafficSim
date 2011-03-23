require "trafficsim"

describe Car, ".next_car_number" do
	it "returns the next car" do
    model = Model.new
    tile = HorizontalTile.new
    model.tile_grid = [[tile]]
    path = tile.paths([0, 25]).first
    model.cars << Car.new(path, 20, [0, 0], model.tile_grid)
    model.cars << Car.new(path, 40, [0, 0], model.tile_grid)
    model.cars[0].number.should == 1
    model.cars[1].number.should == 2
    model.cars[0].next_car_number.should == 2
    model.cars[1].next_car_number.should == -1
    model.cars[0].distance_to_next_car.should == 20
	end
end
