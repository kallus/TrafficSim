class LockablePath < Path
  attr_accessor :crossing_paths
  attr_accessor :number
  @@serial = 0

  def initialize(parameterization, length, end_point)
    super(parameterization, length, end_point)
    @locked = false
    @owner = nil
    @number = @@serial
    @@serial += 1
  end

  def inspect
    "Lockable" + super.to_s
  end

  def try_lock(new_owner)
    if @locked
#      puts "#{new_owner.number} could not lock #{self}, owned by #{@owner.number}" if $debug
      return false
    else
      @owner = new_owner
      @locked = true
#      puts "#{new_owner.number} locked #{self}" if $debug
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
#      puts "#{car.number} released #{self}" if $debug
    end
  end
end
