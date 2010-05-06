class Path
  attr_reader :length
  attr_reader :end_point

  def initialize(parameterization, length, end_point)
    @parameterization = parameterization
    @length = length
    @end_point = end_point
    @cars = []
  end
  
  def point(distance)
    @parameterization.call(distance) unless distance > length
  end
  
  def end_direction
    [end_point[0] == Tile.width ? 1 : (end_point[0] == 0 ? -1 : 0),
    end_point[1] == Tile.height ? 1 : (end_point[1] == 0 ? -1 : 0)]
  end

  def next_entrance_point
    [end_point[0] == Tile.width ? 0 : (end_point[0] == 0 ? Tile.width : end_point[0]),
    end_point[1] == Tile.height ? 0 : (end_point[1] == 0 ? Tile.height : end_point[1])]
  end

  def cars
    sorted = @cars.sort_by { |c| c.distance }  # inefficient but simple
    return sorted
  end

  def add_car!(car)
    @cars << car
  end

  def delete_car!(car)
    if @cars.delete(car) == nil
      puts "tried to remove car which wasn't in this tile"
    end
  end

end
