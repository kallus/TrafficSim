require "trafficsim"
require "view/vector"

settings = {:step => 0.6, :end => 600}

srand(33)
puts rand.to_s

model = Model.new
#model.init_small_town
model.init_town(20,15, 0.7)
#model.init_boring_town

until model.time > settings[:end] do
  print "\r%d%%" % [model.time*100.0/settings[:end]]
  STDOUT.flush
  Vector.draw!(model.cars, model.tile_grid, model.time)
  model.step!(settings[:step])
end
puts ""
