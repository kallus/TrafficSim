class Text
	class << self
		def draw!(cars, tile_grid)
			puts "Tile grid"
			tile_grid.each do |tiles|
				print "Tile row: "
				tiles.each do |t|
					print t.class, "\t"
				end
				puts ""
			end

			puts "\nCars"
			cars.each do |c|
				puts "(%4d,%4d) %3d" % [c.pos[0], c.pos[1], c.angle]
			end
		end
	end
end
