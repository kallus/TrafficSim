require "trafficsim"

settings = {:step => 0.1, :end => 1000, :rand_cars => 60}

$debug = false

for rand_cars in (41..settings[:rand_cars])
  10.times do 
    model = Model.new(settings[:step])
    model.init_town(20,15, 0.4, rand_cars)
    #model.init_town(10,8, 0.4, rand_cars)
    model.init_graph

    i = 0
    until model.time > settings[:end] do
      model.step!
      i += 1
      if model.time > 10 && model.cars.select{|c| !c.rand_car? && !c.dead?}.length == 0
        break
      end
    end

    unless model.cars.select{|c| !c.rand_car? && !c.dead?}.length == 0
      puts "#{rand_cars} NaN"
      next
    end

    avg_lifetime = 0.0
    num_cars = 0
    model.cars.each do |car|
      unless car.rand_car?
        avg_lifetime += car.lifetime
        num_cars += 1
      end
    end
    avg_lifetime = avg_lifetime / num_cars
    puts "#{rand_cars} #{avg_lifetime}"
  end
end
