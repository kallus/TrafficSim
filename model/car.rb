class Car
  attr :x
  attr :y
  attr :angle

  def initialize(x, y, angle)
    @x = x
    @y = y
    @angle = angle
  end

  class << self
    def length
      10
    end

    def width
      5
    end
  end
end
