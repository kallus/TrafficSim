require "trafficsim"
require "view/text"

settings = {:step => 0.8, :end => 5}

model = Model.new

until model.time > settings[:end] do
	Text.draw!(model.cars, model.tile_grid, model.time)
	model.step!(settings[:step])
end
