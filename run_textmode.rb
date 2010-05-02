require "trafficsim"
require "view/text"

model = Model.new

quit = false
until quit do
	Text.draw!(model.cars, model.tile_grid)
	model.step!
	quit = true if "q\n" == gets
end
