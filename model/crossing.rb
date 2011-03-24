class Crossing < Tile
  def initialize
    @locked = false
    @owner = nil
  end

  def try_lock(new_owner)
    if @locked
      return false
    else
      puts "locked"
      @owner = new_owner
      @locked = true
      return true
    end
  end

  def has_lock(car)
    return @owner == car
  end

  def is_locked?
    return @owner != nil
  end

  def release(car)
    if @owner != car
      raise "#{car.number} tried to release lock not owned by this car"
    else
      @owner = nil
      @locked = false
      puts "released"
    end
  end
end
