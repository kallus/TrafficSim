class MapGenerator
  class << self
    def new_map(width, height, connectivity)
      width -= 1 - width % 2 # odd width
      height -= 1 - height % 2 # odd height
      map = [nil] * height
      height.times do |y|
        map[y] = [nil] * width
        width.times do |x|
          cur = EmptyTile.new
          if x == 0 and y == 0
            cur = TurnNeTile.new
          elsif x == width-1 and y == height-1
            cur = TurnSwTile.new
          elsif x == width-1 and y == 0
            cur = TurnNwTile.new
          elsif x == 0 and y == height-1
            cur = TurnSeTile.new
          elsif x == 0 and y % 2 == 0
            cur = TcrossWTile.new
          elsif x == width-1 and y % 2 == 0
            cur = TcrossETile.new
          elsif x % 2 == 0 and y == 0
            cur = TcrossSTile.new
          elsif x % 2 == 0 and y == height-1
            cur = TcrossNTile.new
          elsif x % 2 == 0 and y % 2 == 0
            cur = CrossTile.new
          elsif x % 2 == 0
            cur = VerticalTile.new
          elsif y % 2 == 0
            cur = HorizontalTile.new
          end
          map[y][x] = cur
        end
      end
      remove = ((width / 2)*(height / 2)*(1-connectivity)).to_i
      while remove > 0
        x = (rand * (width-2)).to_i+1
        y = (rand * (height-2)).to_i+1
        tile = map[y][x]
        if tile.kind_of? HorizontalTile and map[y][x-1].kind_of? CrossTile and map[y][x+1].kind_of? CrossTile
          map[y][x] = EmptyTile.new
          map[y][x-1] = TcrossETile.new
          map[y][x+1] = TcrossWTile.new
          remove -= 1
        end
        if tile.kind_of? VerticalTile and map[y-1][x].kind_of? CrossTile and map[y+1][x].kind_of? CrossTile
          map[y][x] = EmptyTile.new
          map[y-1][x] = TcrossNTile.new
          map[y+1][x] = TcrossSTile.new
          remove -= 1
        end
      end
      return map
    end
  end
end
