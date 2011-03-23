class Text
	class << self
		def draw!(cars, tile_grid, time)
      puts "Time: #{time} sec"
      puts "TILES"
			tile_grid.reverse.each do |tiles|
				tiles.each do |t|
					print t.class, "\t"
				end
				puts ""
			end

			puts "CARS"
			cars.each do |c|
				puts "%4d (%4d,%4d) %3d %4.1f %4d" % [c.number, c.pos[0], c.pos[1], c.angle, c.distance_to_next_car, c.next_car_number]
			end
      puts "\n"
		end
	end
end
