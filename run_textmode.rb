require "trafficsim"
require "view/text"

settings = {:step => 0.1, :end => 1}

model = Model.new

until model.time > settings[:end] do
	Text.draw!(model.cars, model.tile_grid, model.time)
	model.step!(settings[:step])
end
