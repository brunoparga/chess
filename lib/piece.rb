class Piece
  # Note on piece colors: The Unicode representations of chess pieces assume
  # black ink on white paper. This game is being developed with a dark background
  # coding environment and terminal. So the actual color of the pieces is reversed
  # from their Unicode names ─ the Unicode for "black pawn" represents a white
  # pawn, etc.
  attr_reader :color, :symbol
  attr_accessor :position

  def initialize(color, position)
    @color = color
    @position = position
  end

  def white(piece)
    "\e[37;1m#{piece}"
  end

  def black(piece)
    "\e[30m#{piece}"
  end

  def piece_moves(board, direction)
    # Used by queens, rooks and bishops.
    # Returns an array of symbols of valid targets in a given direction.
    # Direction 0 is towards rank 8; 1 is towards h8, and so on.
    # So 0 is 'north' or Blackwards, 7 is 'northwest', 4 is 'south' or Whitewards
    file = @position[0].ord - 97
    rank = @position[1].to_i
    dirs = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
    movelist = []
    target = :"#{(file + dirs[direction][0] + 97).chr}#{rank + dirs[direction][1]}"
    # Pieces can move in a given direction however many squares are free.
    while board[target] == ' '
      movelist << target
      target = :"#{((target[0].ord - 97 + dirs[direction][0]) + 97).chr}#{target[1].to_i + dirs[direction][1]}"
    end
    # Pieces can capture enemy pieces.
    if board[target].is_a?(Piece) and board[target].color != @color
      movelist << target
    end
    movelist
  end

  def to_s
    "#{self.color} #{self.class.to_s.downcase}"
  end

end
