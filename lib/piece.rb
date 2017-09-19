class Piece
  # Note on piece colors: The Unicode representations of chess pieces assume
  # black ink on white paper. This game is being developed with a dark background
  # coding environment and terminal. So the actual color of the pieces is reversed
  # from their Unicode names ─ the Unicode for "black pawn" represents a white
  # pawn, etc.
  attr_reader :color, :symbol, :position

  def initialize(color, position)
    @color = color
    @position = position

  end
end

class King < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♔' : '♚'
  end

end

class Queen < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♕' : '♛'
  end

end

class Rook < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♖' : '♜'
  end

end

class Bishop < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♗' : '♝'
  end

end

class Knight < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♘' : '♞'
  end

end

class Pawn < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♙' : '♟'
  end

end
