class LockablePath < Path
  attr_accessor :crossing_paths

  def initialize(parameterization, length, end_point)
    super(parameterization, length, end_point)
    @locked = false
    @owner = nil
  end

  def inspect
    "Lockable" + super.to_s
  end

  def try_lock(new_owner)
    if @locked
      puts "#{new_owner.number} could not lock #{self}, owned by #{@owner.number}"
      return false
    else
      @owner = new_owner
      @locked = true
      puts "#{new_owner.number} locked #{self}"
      return true
    end
  end

  def has_lock?(car)
    return @owner == car
  end

  def is_locked?
    return @owner != nil
  end

  def release(car)
    if @owner != car
      if @owner == nil
        raise "#{car.number} could not release #{self}, owned by noone"
      else
        raise "#{car.number} could not release #{self}, owned by #{@owner.number}"
      end
    else
      @owner = nil
      @locked = false
      puts "#{car.number} released #{self}"
    end
  end
end
