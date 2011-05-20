require "trafficsim"
require "view/vector"

settings = {:step => 0.1, :end => 340, :skip_steps => 20}

$debug = true

srand(33)
puts rand.to_s if $debug

model = Model.new(settings[:step])
#model.init_small_town
#model.init_town(20,15, 0.4, 10)
model.init_town(10,8, 0.4, 10)
#model.init_boring_town
model.init_graph

# create a high res map with path numbers
RVG::dpi = 144/3
t = model.time
model.time = -1
Vector.draw!(model.cars, model.tile_grid, model.time)
model.time = t
#RVG::dpi = 144/8

i = 0
until model.time > settings[:end] do
  print "\r%d%%" % [model.time*100.0/settings[:end]]
  STDOUT.flush
  Vector.draw!(model.cars, model.tile_grid, model.time) if i % settings[:skip_steps] == 0
  model.step!
  i += 1
end
puts ""

avg_lifetime = 0.0
num_cars = 0
model.cars.each do |car|
#  puts "#{car.number} lifetime: #{car.lifetime}"
  unless car.rand_car?
    avg_lifetime += car.lifetime
    num_cars += 1
  end
end
avg_lifetime = avg_lifetime / num_cars
puts "average lifetime: #{avg_lifetime}"
puts "num of drive through cars: #{num_cars}"
