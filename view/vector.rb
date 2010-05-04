require 'rvg/rvg'
include Magick

RVG::dpi = 144/2

class Vector
  class << self
    def draw!(cars, tile_grid, time)
      grid_size = [tile_grid[0].length,tile_grid.length]
      size = [grid_size[0]*Tile.width,grid_size[1]*Tile.height]
      @rvg = RVG.new(
          (grid_size[0]*2.5).in,
          (grid_size[1]*2.5).in
        ).viewbox(0,0,size[0],size[1]) do |canvas|
        canvas.background_fill = 'white'
        canvas.matrix(1, 0, 0, -1, 0, (grid_size[1]*2.5).in) #changing to cartesian coordinates

        canvas.g.translate(0,2).matrix(1,0,0,-1,0,0).scale(0.5).text(0, 0, "Time: %.2f sec" % [time])

        tile_grid.each_with_index do |tiles, y|
          tiles.each_with_index do |tile, x|
            tile!(canvas, tile, x*Tile.width, y*Tile.height)
          end
        end

        cars.each do |car|
          car!(canvas, car)
        end

      end

      @rvg.draw.write("output/#{("%06.2f" % [time]).sub(".", "")}.gif")
    end

    def tile!(canvas, tile, x, y)
      canvas.g.translate(x, y) do |solid|
        solid.styles(:stroke=>'black', :stroke_width=>0.2)
        case tile
          when HorizontalTile
            solid.line(0, 35, Tile.width, 35)
            solid.line(0, 25, Tile.width, 25)
          when TurnSwTile
            path!(solid, tile.paths([0,25]).first)
            path!(solid, tile.paths([35,0]).first)
          when TurnNeTile
            path!(solid, tile.paths([Tile.width,35]).first)
            path!(solid, tile.paths([25,Tile.height]).first)
          when TurnNwTile
            path!(solid, tile.paths([0,25]).first)
            path!(solid, tile.paths([25,Tile.height]).first)
          when TurnSeTile
            path!(solid, tile.paths([Tile.width,35]).first)
            path!(solid, tile.paths([35,0]).first)
          when TcrossNTile
            paths = tile.paths([0,25]) + tile.paths([35,0]) + tile.paths([Tile.width,35])
            paths.each { |p| path!(solid,p)}
          when TcrossSTile
            paths = tile.paths([0,25]) + tile.paths([25,Tile.height]) + tile.paths([Tile.width,35])
            paths.each { |p| path!(solid,p)}
        end
      end
    end

    def car!(canvas, car)
      canvas.g.translate(*car.pos).rotate(car.angle) do |c|
        c.styles(:fill => 'black', :stroke => "black", :stroke_width => 0.1)
        c.circle(0.5,0,0)
        c.g.translate(1,1).matrix(1,0,0,-1,0,0).scale(0.25).text(0,0, "Speed: %.1f m/s" % [car.speed])
#c.g.translate(1,1).matrix(1,0,0,-1,0,0).scale(0.2).text(0,0, "(%d,%d)\n(%d,%d)\n%s\n(%d,%d)\n(%d,%d)" % (car.grid_pos + car.next_grid_pos + [car.tile.class] + car.current_path.end_point + car.current_path.end_direction))
      end
      canvas.g.translate(*car.tail).rotate(car.angle) do |c|
        c.styles(:fill => 'black', :stroke => "black", :stroke_width => 0.1)
        c.circle(0.5,0,0)
      end
      canvas.line(*(car.pos+car.tail))
    end

    def path!(canvas, path)
      (1..path.length).to_a.each do |i|
        canvas.line(*(path.point(i-1) + path.point(i)))
      end
      canvas.line(*(path.point(path.length-1) + path.end_point))
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
