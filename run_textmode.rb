require "trafficsim"
require "view/text"

settings = {:step => 1, :end => 60}

model = Model.new
model.init_small_town

#until model.time > settings[:end] do
model.step!(settings[:step])
until model.cars.select{|c| not c.dead}.length == 0 do
	#Text.draw!(model.cars, model.tile_grid, model.time)
	model.step!(settings[:step])
  puts model.cars.select{|c| not c.dead}.length
end
