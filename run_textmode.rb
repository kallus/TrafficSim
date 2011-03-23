require "trafficsim"
require "view/text"

settings = {:step => 1, :end => 60}

model = Model.new
model.init_small_town

until model.time > settings[:end] do
	Text.draw!(model.cars, model.tile_grid, model.time)
	model.step!(settings[:step])
end
