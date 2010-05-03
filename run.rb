require "trafficsim"
require "view/vector"

model = Model.new
Vector.draw!(model.cars, model.tile_grid)
