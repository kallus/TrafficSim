class Tile
  def paths(entrance_point)
    @paths.select{|p| p.point(0) == entrance_point}
  end

  def start_pos
    @start_positions.shift
  end

  def step!(time, model)
  end

  class << self
    def width
      60
    end

    def height
      60
    end
  end
end
