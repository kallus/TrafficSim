require "trafficsim"
require "view/vector"

settings = {:step => 0.3, :end => 60}

model = Model.new
model.init_small_town

until model.time > settings[:end] do
  print "\r%d%%" % [model.time*100.0/settings[:end]]
  STDOUT.flush
  Vector.draw!(model.cars, model.tile_grid, model.time)
  model.step!(settings[:step])
end
puts ""
