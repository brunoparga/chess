require_relative "piece"
require_relative "move_checker"

class King < Piece

  # Castling requires the squares the king passes through not be threatened by
  # opposing pieces, so Move_checker#possible_moves is used.
  include Move_checker

  attr_writer :has_moved

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? black("♚") : white("♚")
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
    # This method tells whether castling is possible. Possible castles are
    # returned in an array. The actual move is handled elsewhere.
    rank = (@color == :black ? 8 : 1)
    castle = []
    # If the king hasn't moved so far in the game...
    if not @has_moved
      # ...and the kingside rook is at its starting square...
      if board[:"h#{rank}"].is_a?(Rook) and
        # ... and it hasn't moved...
        (not board[:"h#{rank}"].has_moved) and
        # ...and the squares between them are empty and not under attack...
        squares(board, :kingside, rank)
        # ... then kingside castling is an option.
        castle << :"g#{rank}"
      end
      # Same here: check if the queenside rook hasn't moved
      if board[:"a#{rank}"].is_a?(Rook) and
        (not board[:"a#{rank}"].has_moved) and
        # the three squares between them are empty and unthreatened
        squares(board, :queenside, rank)
        # Queenside castling is an option
        castle << :"c#{rank}"
      end
    end
    castle
  end

  def squares(board, side, rank)
    # Verify that the necessary squares are free and unthreatened for castling.
    return false if side == :queenside and board[:"b#{rank}"] != ' '
    pass = [:"f#{rank}", :"g#{rank}"] if side == :kingside
    pass = [:"c#{rank}", :"d#{rank}"] if side == :queenside
    pass.each { |square| return false if board[square] != ' '}
    opponent = (@color == :black ? :white : :black)
    opp_possible = possible_moves(board, opponent, true).values.flatten
    pass.each do |square|
      return false if opp_possible.include?(square)
    end
    return true
  end

end
