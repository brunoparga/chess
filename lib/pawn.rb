require_relative "piece"

class Pawn < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? black("♟") : white("♟")
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    direction = (@color == :black) ? -1 : 1
    file = @position[0].ord - 97
    rank = @position[1].to_i
    pawn_moves = []
    target1 = :"#{(file + 97).chr}#{rank + direction}"
    # If the space ahead of it is clear...
    if board[target1] == ' '
      # The pawn can move into it.
      pawn_moves << target1
      # Furthermore, if it is in its original rank...
      if rank == (@color == :black ? 7 : 2)
        target2 = :"#{(file + 97).chr}#{rank + 2 * direction}"
        # ... and the space two ranks ahead is also clear...
        if board[target2] == ' '
          # It can move two ranks.
          pawn_moves << target2
        end
      end
    end
    # These are the possible squares the pawn can capture to.
    capture1 = :"#{(file + 96).chr}#{rank + direction}"
    capture2 = :"#{(file + 98).chr}#{rank + direction}"
    # If there's an opposing piece in either adjoining file, in the correct rank...
    [capture1, capture2].each do |target|
      if (board[target].is_a?(Piece) and board[target].color != @color) or (target == board.en_passant)
        # ... it can capture.
        pawn_moves << target
      end
    end
    pawn_moves
  end

end
