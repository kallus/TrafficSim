require 'rvg/rvg'
include Magick

RVG::dpi = 144

class Vector
  class << self
    def draw!(cars, tile_grid, time)
      @rvg = RVG.new(
          (tile_grid[0].length*2.5).in,
          (tile_grid.length*2.5).in
        ).viewbox(0,0,tile_grid[0].length*Tile.width,tile_grid.length*Tile.height) do |canvas|
        canvas.background_fill = 'white'

        canvas.g.scale(0.5).text(2, 15, "Time: #{time} sec")

        tile_grid.reverse.each_with_index do |tiles, y|
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
            solid.path('M0,25 a25,25 0 0,0 25,-25').styles(:fill=>'none')
            solid.path('M0,35 a35,35 0 0,0 35,-35').styles(:fill=>'none')
        end
      end
    end

    def car!(canvas, car)
      canvas.g.translate(*car.pos).rotate(car.angle) do |c|
        c.styles(:fill => 'white', :stroke => "black", :stroke_width => 0.1)
        c.circle(2,0,0)
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
