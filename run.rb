require "trafficsim"
require "view/vector"

settings = {:step => 0.6, :end => 2400, :skip_steps => 10}

$debug = false

srand(33)
puts rand.to_s

model = Model.new
#model.init_small_town
model.init_town(20,15, 0.4)
#model.init_boring_town
model.init_graph

# create a high res map with path numbers
RVG::dpi = 144/2
t = model.time
model.time = -1
Vector.draw!(model.cars, model.tile_grid, model.time)
model.time = t
RVG::dpi = 144/8

i = 0
until model.time > settings[:end] do
  print "\r%d%%" % [model.time*100.0/settings[:end]]
  STDOUT.flush
  Vector.draw!(model.cars, model.tile_grid, model.time) if i % settings[:skip_steps] == 0
  model.step!(settings[:step])
  i += 1
end
puts ""
