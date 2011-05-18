class CarCreator
  def initialize(cars, model, grid_pos, paths, cars_per_second, count)
    @model = model
    @grid_pos = grid_pos
    @paths = paths
    @cars_per_second = cars_per_second
    @cars = cars
    @count = count

    @time = 0
  end

  def step!(time) #seconds
    @time += time
    @path = @paths[rand(@paths.length)]
    if @time > 1.0/@cars_per_second and crossing_is_clear? and @count > 0
      create!
      @time = 0
      @count -= 1
    end
  end

  def create!
    if crossing_is_clear?
      @cars << Car.new(@path, 10, @grid_pos, @model, @model.out_paths(@grid_pos))
    end
  end

  private
  def crossing_is_clear?
    return false if @path.is_locked?
    @path.crossing_paths.each do |p|
      return false if p.is_locked?
    end
  end
end
