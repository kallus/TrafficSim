class Model
  attr :state

  def initialize
    @state = State.new
    @state.tile_rows << [Tile.new, Tile.new, Tile.new]
    @state.tile_rows.each do |row|
      row.each do |tile|
        pos = tile.first_free_pos
        @state.cars << Car.new(pos[:x], pos[:y], pos[:angle])
      end
    end
  end
end
