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
        if tile.kind_of? HorizontalTile
          right = map[y][x+1]
          left = map[y][x-1]
          if not right.kind_of? HorizontalTile and not left.kind_of? HorizontalTile and not right.kind_of? TurnNwTile and not right.kind_of? TurnSwTile and not left.kind_of? TurnNeTile and not left.kind_of? TurnSeTile
            if right.kind_of? CrossTile
              right = TcrossWTile.new
            elsif right.kind_of? TcrossETile
              right = VerticalTile.new
            elsif right.kind_of? TcrossNTile
              right = TurnSeTile.new
            elsif right.kind_of? TcrossSTile
              right = TurnNeTile.new
            end
            if left.kind_of? CrossTile
              left = TcrossETile.new
            elsif left.kind_of? TcrossWTile
              left = VerticalTile.new
            elsif left.kind_of? TcrossNTile
              left = TurnSwTile.new
            elsif left.kind_of? TcrossSTile
              left = TurnNwTile.new
            end
            remove -= 1
            map[y][x+1] = right
            map[y][x-1] = left
            map[y][x] = EmptyTile.new
          end
        end
        if tile.kind_of? VerticalTile
          above = map[y+1][x]
          below = map[y-1][x]
          if not above.kind_of? VerticalTile and not below.kind_of? VerticalTile and not above.kind_of? TurnSeTile and not above.kind_of? TurnSwTile and not below.kind_of? TurnNeTile and not below.kind_of? TurnNwTile
            if above.kind_of? CrossTile
              above = TcrossSTile.new
            elsif above.kind_of? TcrossNTile
              above = HorizontalTile.new
            elsif above.kind_of? TcrossWTile
              above = TurnNeTile.new
            elsif above.kind_of? TcrossETile
              above = TurnNwTile.new
            end
            if below.kind_of? CrossTile
              below = TcrossNTile.new
            elsif below.kind_of? TcrossSTile
              below = HorizontalTile.new
            elsif below.kind_of? TcrossWTile
              below = TurnSeTile.new
            elsif below.kind_of? TcrossETile
              below = TurnSwTile.new
            end
            remove -= 1
            map[y+1][x] = above
            map[y-1][x] = below
            map[y][x] = EmptyTile.new
          end
        end
      end
      return map
    end
  end
end
