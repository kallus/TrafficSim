require "trafficsim"
require "view/vector"

settings = {:step => 0.8, :end => 5}

model = Model.new

until model.time > settings[:end] do
	Vector.draw!(model.cars, model.tile_grid, model.time)
	model.step!(settings[:step])
end
