class Tile
  def initialize
    @start_positions = [
      {:x => 2, :y => 28, :taken => false, :angle => 180},
      {:x => Car.length + 4, :y => 28, :taken => false, :angle => 180},
      {:x => Car.length * 2 + 4, :y => 28, :taken => false, :angle => 180},
      {:x => Car.length + 2, :y => 32, :taken => false, :angle => 0},
      {:x => Car.length * 2 + 2, :y => 32, :taken => false, :angle => 0},
      {:x => Car.length * 3 + 2, :y => 32, :taken => false, :angle => 0},
    ]
  end

  def first_free_pos
    pos = @start_positions.select{|p| !p[:taken]}
    return false if pos.empty?
    pos = pos.first
    pos[:taken] = true
    pos
  end

  def solid_lines
    [
      [0, 20, self.class.width, 20],
      [0, 40, self.class.width, 40]
    ]
  end

  def marked_lines
    [
      [0, 30, self.class.width, 30]
    ]
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
