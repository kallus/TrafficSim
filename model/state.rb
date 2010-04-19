class State
  attr :time
  attr :tile_rows
  attr :cars

  def initialize
    @tile_rows = []
    @cars = []
  end

  def width
    tile_rows.first.count * Tile.width
  end

  def height
    tile_rows.count * Tile.height
  end
end
