require_relative "piece"

class King < Piece

  attr_writer :has_moved

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♔' : '♚'
    @has_moved = false
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    file = @position[0].ord - 97
    rank = @position[1].to_i
    dirs = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
    king_moves = []
    8.times do |dir|
      target = :"#{(file + dirs[dir][0] + 97).chr}#{rank + dirs[dir][1]}"
      if board[target] == ' ' or
        (board[target].is_a?(Piece) and board[target].color != @color)
        king_moves << target
      end
    end
    king_moves << can_castle(board)
    king_moves.flatten!
  end

  def can_castle(board)
    # This method tells whether castling is possible. The actual move is
    # handled elsewhere.
    rank = (@color == :black ? 8 : 1)
    castle = []
    # If the king hasn't moved so far in the game...
    if not @has_moved
      # ...and the kingside rook is at its starting square...
      if board[:"h#{rank}"].is_a?(Rook) and
        (not board[:"h#{rank}"].has_moved) and
        # ...and the squares between them are empty...
        # TODO: and those squares are not under attack
        # squares(kingside, rank)
        board[:"f#{rank}"] == ' ' and
        board[:"g#{rank}"] == ' '
        # ... then kingside castling is an option.
        castle << :"g#{rank}"
      end
      # Same here: check if the queenside rook hasn't moved
      if board[:"a#{rank}"].is_a?(Rook) and
        (not board[:"a#{rank}"].has_moved) and
        # check that the three squares between them are empty
        # TODO: check for threats to these squares
        # squares(queenside, rank)
        board[:"b#{rank}"] == ' ' and
        board[:"c#{rank}"] == ' ' and
        board[:"d#{rank}"] == ' ' and
        # Queenside castling is an option
        castle << :"c#{rank}"
      end
    end
    castle
  end

  def squares(side, rank)
    pass = [:"f#{rank}", :"g#{rank}"] if side == kingside
    pass = [:"c#{rank}", :"d#{rank}"] if side == queenside
    opponent = (@color == :black ? :white : :black)
  end

end
