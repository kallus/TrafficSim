require "trafficsim"
require "view/vector"

settings = {:step => 1.8, :end => 20}

model = Model.new

until model.time > settings[:end] do
	Vector.draw!(model.cars, model.tile_grid, model.time)
	model.step!(settings[:step])
end
