class Chess
  # A game of chess, playable on the command line.

  attr_reader :board

  def initialize
    # The board is a hash. Each key is the symbol of the name of the square
    # (e.g. :a1). The value is a Square object.
    @board = initialize_board
  end

  def initialize_board
    board = Hash.new
    ('a'..'h').each do |file|
      (1..8).each do |rank|
        name = ("#{file}#{rank.to_s}").to_sym
        square = Square.new(file, rank)
        board[name] = square
      end
    end
    board
  end

  def display_board

  end

end

class Square
  # A square on the chessboard. It has instance variables for its position on
  # the board (from a1 to h8) and for the piece currently occupying it.

  attr_reader :file, :rank, :position

  def initialize(file, rank)
    @file = file
    @rank = rank
    @position = ("#{file}#{rank.to_s}").to_sym
    @piece = nil
  end

end

class Piece
  # A note on piece colors. The Unicode representations of chess pieces assume
  # black ink on white paper. This game is being developed with a dark background
  # coding environment and terminal. So the actual color of the pieces is reversed
  # from their Unicode names ─ the Unicode for "black pawn" represents a white
  # pawn, etc.
  attr_reader :color, :symbol

  def initialize(color)
    @color = color

  end
end

class King < Piece

  def initialize(color)
    super
    @symbol = @color == :black ? '♔' : '♚'
  end

end

class Queen < Piece

  def initialize(color)
    super
    @symbol = @color == :black ? '♕' : '♛'
  end

end

class Rook < Piece

  def initialize(color)
    super
    @symbol = @color == :black ? '♖' : '♜'
  end

end

class Bishop < Piece

  def initialize(color)
    super
    @symbol = @color == :black ? '♗' : '♝'
  end

end

class Knight < Piece

  def initialize(color)
    super
    @symbol = @color == :black ? '♘' : '♞'
  end

end

class Pawn < Piece

  def initialize(color)
    super
    @symbol = @color == :black ? '♙' : '♟'
  end

end
