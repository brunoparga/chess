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

  def possible_moves(board, direction)
    # Used by queens, rooks and bishops.
    # Returns an array of symbols of valid targets in a given direction.
    # Direction 0 is towards rank 8; 1 is towards h8, and so on.
    # So 0 is 'north' or Blackwards, 7 is 'northwest', 4 is 'south' or Whitewards
    file = @position[0].ord - 97
    rank = @position[1].to_i
    dirs = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
    moves = []
    target = :"#{(file + dirs[direction][0] + 97).chr}#{rank + dirs[direction][1]}"
    # Pieces can move in a given direction however many squares are free.
    while board[target] == ' '
      moves << target
      target = :"#{((target[0].ord - 97 + dirs[direction][0]) + 97).chr}#{target[1].to_i + dirs[direction][1]}"
    end
    # Pieces can capture enemy pieces.
    if board[target].is_a?(Piece) and board[target].color != @color
      moves << target
    end
    moves
  end

  def to_s
    "#{self.color} #{self.class.to_s.downcase}"
  end

end

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
    file = (@color == :black ? 8 : 1)
    castle = []
    # If the king hasn't moved so far in the game...
    if not @has_moved
      # ...and the kingside rook is at its starting square...
      if board[:"h#{file}"].is_a?(Rook) and
        (not board[:"h#{file}"].has_moved) and
        # ...and the squares between them are empty...
        # TODO: and those squares are not under attack
        board[:"f#{file}"] == ' ' and
        board[:"g#{file}"] == ' '
        # ... then kingside castling is an option.
        castle << :"g#{file}"
      end
      # Same here: check if the queenside rook hasn't moved
      if board[:"a#{file}"].is_a?(Rook) and
        (not board[:"a#{file}"].has_moved) and
        # check that the three squares between them are empty
        # TODO: check for threats to these squares
        board[:"b#{file}"] == ' ' and
        board[:"c#{file}"] == ' ' and
        board[:"d#{file}"] == ' ' and
        # Queenside castling is an option
        castle << :"c#{file}"
      end
    end
    castle
  end

end

class Queen < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♕' : '♛'
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    queen_moves = []
    8.times do |direction|
      queen_moves << possible_moves(board, direction)
    end
    queen_moves.flatten!
  end

end

class Rook < Piece

  attr_accessor :has_moved

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♖' : '♜'
    @has_moved = false
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    rook_moves = []
    4.times do |direction|
      rook_moves << possible_moves(board, direction * 2)
    end
    rook_moves.flatten!
  end

end

class Bishop < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♗' : '♝'
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    bishop_moves = []
    4.times do |direction|
      bishop_moves << possible_moves(board, direction * 2 + 1)
    end
    bishop_moves.flatten!
  end

end

class Knight < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♘' : '♞'
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    file = @position[0].ord - 97
    rank = @position[1].to_i
    moves = []
    ones = [-1, 1]
    twos = [-2, 2]
    ones.map do |ones|
      twos.map do |twos|
        target1 = :"#{(file + ones + 97).chr}#{rank + twos}"
        target2 = :"#{(file + twos + 97).chr}#{rank + ones}"
        [target1, target2].each do |target|
          if board[target] == ' ' or
            (board[target].is_a?(Piece) and board[target].color != @color)
            moves << target
          end
        end
      end
    end
    moves
  end

end

class Pawn < Piece

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♙' : '♟'
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    direction = (@color == :black) ? -1 : 1
    file = @position[0].ord - 97
    rank = @position[1].to_i
    moves = []
    target1 = :"#{(file + 97).chr}#{rank + direction}"
    # If the space ahead of it is clear...
    if board[target1] == ' '
      # The pawn can move into it.
      moves << target1
      # Furthermore, if it is in its original rank...
      if rank == (@color == :black ? 7 : 2)
        target2 = :"#{(file + 97).chr}#{rank + 2 * direction}"
        # ... and the space two ranks ahead is also clear...
        if board[target2] == ' '
          # It can move two ranks.
          moves << target2
        end
      end
    end
    capture1 = :"#{(file + 96).chr}#{rank + direction}"
    capture2 = :"#{(file + 98).chr}#{rank + direction}"
    # If there's an opposing piece in either adjoining file, in the correct rank...
    [capture1, capture2].each do |target|
      if board[target].is_a?(Piece) and board[target].color != @color
        moves << target
      end
    end
    moves
  end

end
