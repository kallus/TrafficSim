require 'rvg/rvg'
include Magick

RVG::dpi = 144/8

class Vector
  class << self
    def draw!(cars, tile_grid, time)
      grid_size = [tile_grid[0].length,tile_grid.length]
      size = [grid_size[0]*Tile.width,grid_size[1]*Tile.height]
      if @rvg == nil
        puts "drawing map"
        @rvg = RVG.new((grid_size[0]*2.5).in,
                       (grid_size[1]*2.5).in
                       ).viewbox(0,0,size[0],size[1]) do |canvas|
          canvas.background_fill = 'white'
          canvas.matrix(1, 0, 0, -1, 0, (grid_size[1]*2.5).in) #changing to cartesian coordinates

          tile_grid.each_with_index do |tiles, y|
            tiles.each_with_index do |tile, x|
              tile!(canvas, tile, x*Tile.width, y*Tile.height)
            end
          end
        end
        @rvg.draw.write("output/map.gif")
      end

      frame_rvg = RVG.new((grid_size[0]*2.5).in,
                          (grid_size[1]*2.5).in).viewbox(0,0,size[0],size[1]) do |c|
#        c.background_fill = 'white'
        c.background_image = Magick::Image.read('output/map.gif').first
        c.matrix(1, 0, 0, -1, 0, (grid_size[1]*2.5).in) #changing to cartesian coordinates
        c.g.translate(0,2).matrix(1,0,0,-1,0,0).scale(0.5).text(0, 0, "Time: %.2f sec" % [time])

        width = 2.5
        wheels = RVG::Group.new do |_wheels|
          _wheels.styles(:fill => 'black', :stroke => "black", :stroke_width => 0.1)
          _wheels.rect(1, width/4.0, -(Car.length), width/2.0)  # back, left
          _wheels.rect(1, width/4.0, -(Car.length), -width/2.0 - width/4.0) # back, right
          _wheels.rect(1, width/4.0, -2.0, width/2.0)  # front, left
          _wheels.rect(1, width/4.0, -2.0, -width/2.0 - width/4.0)  #front, right
        end

        car_body = RVG::Group.new do |_car_body|
          _car_body.styles(:fill => 'blue', :stroke => 'blue', :stroke_width => 0.1)
          _car_body.rect(Car.length, width, -Car.length, -width/2)
        end

        car_graphics = RVG::Group.new do |_cg|
          _cg.use(wheels)
          _cg.use(car_body)
        end

        random_car_body = RVG::Group.new do |_car_body|
          _car_body.styles(:fill => 'red', :stroke => 'red', :stroke_width => 0.1)
          _car_body.rect(Car.length, width, -Car.length, -width/2)
        end

        random_car_graphics = RVG::Group.new do |_cg|
          _cg.use(wheels)
          _cg.use(random_car_body)
        end

        cars.each do |car|
          unless car.dead
            if car.rand_car?
              car!(c, car, random_car_graphics)
            else
              car!(c, car, car_graphics)
            end
          end
        end
      end

      frame_rvg.draw.write("output/#{("%06.2f" % [time]).sub(".", "")}.gif")
    end

    @@hlines = RVG::Group.new do |s|
      s.styles(:stroke => 'black', :stroke_width => 0.2)
      s.line(0, 35+Car.width, Tile.width, 35+Car.width)
      s.line(0, 25-Car.width, Tile.width, 25-Car.width)
    end
    @@separating_line = RVG::Group.new do |s|
      s.styles(:stroke => 'black', :fill => 'none', :stroke_dasharray => [2, 4], :stroke_width => 0.2)
      s.line(0, 30, Tile.width, 30)
    end
    @@straight_tile = RVG::Group.new do |s|
      s.use(@@hlines)
      s.use(@@separating_line)
    end

    @@tcross_lines = RVG::Group.new do |s|
      s.styles(:stroke => 'black', :stroke_width => 0.2)
      s.line(0, 25-Car.width, Tile.width, 25-Car.width)

      s.line(0, 35+Car.width, Tile.width/2 - 10, 35+Car.width)
      s.line(Tile.width/2 - 10, 35+Car.width, Tile.width/2 - 10, Tile.height)

      s.line(Tile.width/2 + 10, 35+Car.width, Tile.width, 35+Car.width)
      s.line(Tile.width/2 + 10, 35+Car.width, Tile.width/2 + 10, Tile.height)
    end
    @@tcross_tile = RVG::Group.new do |s|
      s.use(@@tcross_lines)
    end

    @@turn_lines = RVG::Group.new do |s|
      s.styles(:stroke => 'black', :stroke_width => 0.2)
      s.line(0, Tile.width/2 + 10, Tile.width/2 + 10, Tile.width/2 + 10)
      s.line(Tile.width/2 + 10, Tile.width/2 + 10, Tile.width/2 + 10, 0)

      s.line(0, Tile.width/2 - 10, Tile.width/2 - 10, Tile.width/2 - 10)
      s.line(Tile.width/2 - 10, Tile.width/2 - 10, Tile.width/2 - 10, 0)
    end
    @@turn_separating_line = RVG::Group.new do |s|
      s.styles(:stroke => 'black', :fill => 'none', :stroke_dasharray => [2, 4], :stroke_width => 0.2)
      s.line(0, 30, Tile.width/2, 30)
      s.line(Tile.width/2, 0, Tile.width/2, 30)
    end
    @@turn_tile = RVG::Group.new do |s|
      s.use(@@turn_lines)
      s.use(@@turn_separating_line)
    end
    
    def tile!(canvas, tile, x, y)
      canvas.g.translate(x, y) do |solid|
#        if $debug == true and tile.all_paths != nil
#          path_nums = tile.all_paths.collect { |p| p.number.to_s }
#          path_groups = []
#          path_nums.each_slice(3) { |g3| path_groups << g3.join(", ") }
#          path_string = path_groups.join(",\n")
#          if path_string.length > 0
#            solid.g.matrix(1,0,0,-1,0,0).translate(0, -20).scale(0.3).text(0, 0, path_string)
#          end
#        end

        solid.styles(:stroke=>'black', :stroke_width=>0.2)
        case tile
          when HorizontalTile
            solid.use(@@straight_tile)
          when VerticalTile
            solid.use(@@straight_tile).rotate(90).translate(*[0, -Tile.width])
#            solid.line(25, 0, 25, Tile.height)
#            solid.line(35, 0, 35, Tile.height)
          when TurnSwTile
            solid.use(@@turn_tile)
#            path!(solid, tile.paths([0,25]).first)
#            path!(solid, tile.paths([35,0]).first)
          when TurnNeTile
            solid.use(@@turn_tile).rotate(180).translate(*[-Tile.width, -Tile.height])
#            path!(solid, tile.paths([Tile.width,35]).first)
#            path!(solid, tile.paths([25,Tile.height]).first)
          when TurnNwTile
            solid.use(@@turn_tile).rotate(-90).translate(*[-Tile.width, 0])
#            path!(solid, tile.paths([0,25]).first)
#            path!(solid, tile.paths([25,Tile.height]).first)
          when TurnSeTile
            solid.use(@@turn_tile).rotate(90).translate(*[0, -Tile.width])
#            path!(solid, tile.paths([Tile.width,35]).first)
#            path!(solid, tile.paths([35,0]).first)
          when TcrossNTile
            solid.use(@@tcross_tile).rotate(180).translate(*[-Tile.width, -Tile.height])
#            paths = tile.paths([0,25]) + tile.paths([35,0]) + tile.paths([Tile.width,35])
#            paths.each { |p| path!(solid,p)}
          when TcrossSTile
            solid.use(@@tcross_tile)
#            paths = tile.paths([0,25]) + tile.paths([25,Tile.height]) + tile.paths([Tile.width,35])
#            paths.each { |p| path!(solid,p)}
          when TcrossETile
            solid.use(@@tcross_tile).rotate(90).translate(*[0, -Tile.width])
#            paths = tile.paths([0,25]) + tile.paths([25,Tile.height]) + tile.paths([35,0])
#            paths.each { |p| path!(solid,p)}
          when TcrossWTile
            solid.use(@@tcross_tile).rotate(-90).translate(*[-Tile.width, 0])
#            paths = tile.paths([Tile.width,35]) + tile.paths([25,Tile.height]) + tile.paths([35,0])
#            paths.each { |p| path!(solid,p)}
          when CrossTile
            paths = []
            paths += tile.paths([Tile.width,35]) # from east
            paths += tile.paths([25,Tile.height]) # from north
            paths += tile.paths([35,0]) # from south
            paths += tile.paths([0, 25]) # from west
            paths.each { |p| path!(solid,p)}
          when EmptyTile
          else
            raise "Unknown tile"
        end
      end
    end

    def car!(canvas, car, car_graphics)
#      text_group = RVG::Group.new do |s|
#        s.translate(*[car.pos[0], car.pos[1]+3]).matrix(1,0,0,-1,0,0).scale(0.3).text(0,0, "%d (%.1f m/s, %.1f m/s^2, %d %.1f m)" % [car.number, car.speed, car.acceleration, car.next_car_number, car.distance_to_next_obstruction])
#      end
      canvas.g do |s|
#        s.use(text_group)
        s.use(car_graphics).translate(*car.pos).rotate(car.angle)
      end
    end

    def path!(solid, path)
      if path.kind_of?(LockablePath) and path.is_locked?
        solid.g.translate(0, 0) do |s|
          s.styles(:stroke=>'red', :stroke_width=>0.8) 
          (1..path.length).to_a.each do |i|
            s.line(*(path.point(i-1) + path.point(i)))
          end
          s.line(*(path.point(path.length-1) + path.end_point))
        end
      else
        solid.g.translate(0, 0) do |s|
          s.styles(:stroke=>'black', :stroke_width=>0.2) 
          (1..path.length).to_a.each do |i|
            s.line(*(path.point(i-1) + path.point(i)))
          end
          s.line(*(path.point(path.length-1) + path.end_point))
        end
      end
    end
  end
end
#        c.rect(Car.length, Car.width, car.x-Car.length, car.y)
        
        #arrow
#        x = car.x-0.15*Car.length 
#        y = car.y+Car.width*0.5
#        c.line(car.x-Car.length+0.15*Car.length,
#          car.y+Car.width*0.5,
#          x,
#          y)
#        c.line(x, y, x-Car.length*0.15, y-Car.width*0.25)
#        c.line(x, y, x-Car.length*0.15, y+Car.width*0.25)
#      end

#    canvas.g.translate(100, 150).rotate(-30) do |body|
#        body.styles(:fill=>'yellow', :stroke=>'black', :stroke_width=>2)
#        body.ellipse(50, 30)
#        body.rect(45, 20, -20, -10).skewX(-35)
#    end

#    canvas.g.translate(130, 83) do |head|
#        head.styles(:stroke=>'black', :stroke_width=>2)
#        head.circle(30).styles(:fill=>'yellow')
#        head.circle(5, 10, -5).styles(:fill=>'black')
#        head.polygon(30,0, 70,5, 30,10, 62,25, 23,20).styles(:fill=>'orange')
#    end
#
#    foot = RVG::Group.new do |_foot|
#        _foot.path('m0,0 v30 l30,10 l5,-10, l-5,-10 l-30,10z').
#              styles(:stroke_width=>2, :fill=>'orange', :stroke=>'black')
#    end
#    canvas.use(foot).translate(75, 188).rotate(15)
#    canvas.use(foot).translate(100, 185).rotate(-15)

#    canvas.text(125, 30) do |title|
#        title.tspan("duck|").styles(:text_anchor=>'end', :font_size=>20,
#                       :font_family=>'helvetica', :fill=>'black')
#        title.tspan("type").styles(:font_size=>22,
#               :font_family=>'times', :font_style=>'italic', :fill=>'red')
#    end
#    canvas.rect(249,249).styles(:stroke=>'blue', :fill=>'none')
