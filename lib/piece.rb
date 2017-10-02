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
    target = "#{(file + dirs[direction][0] + 97).chr}#{rank + dirs[direction][1]}".to_sym
    # Pieces can move in a given direction however many squares are free.
    while board[target] == ' '
      moves << target
      target = "#{((target[0].ord - 97 + dirs[direction][0]) + 97).chr}#{target[1].to_i + dirs[direction][1]}".to_sym
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

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♔' : '♚'
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    file = @position[0].ord - 97
    rank = @position[1].to_i
    dirs = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
    moves = []
    8.times do |dir|
      target = "#{(file + dirs[dir][0] + 97).chr}#{rank + dirs[dir][1]}".to_sym
      if board[target] == ' ' or
        (board[target].is_a?(Piece) and board[target].color != @color)
        moves << target
      end
    end
    moves
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

  def initialize(color, position)
    super
    @symbol = (@color == :black) ? '♖' : '♜'
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
        target1 = "#{(file + ones + 97).chr}#{rank + twos}".to_sym
        target2 = "#{(file + twos + 97).chr}#{rank + ones}".to_sym
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

  def pawn_move(board, target)
    direction = (@color == :black) ? -1 : 1
    from_file = @position[0]
    from_rank = @position[1].to_i
    target_file = target[0]
    target_rank = target[1].to_i
    ahead = target_rank - from_rank
    sideways = (from_file.ord - target_file.ord).abs
    if sideways > 1
      return "Invalid move: pawns must move within the same file or capture in adjacent files."
    elsif sideways == 1
      if direction == ahead and board[target] != ' ' and board[target].color != @color
        return true
      elsif direction == ahead and board[target] != ' ' and board[target].color == @color
        return "Invalid move: pawn blocked by another #{@color} piece."
      elsif direction == ahead and board[target] == ' '
        return "Invalid move: pawns can only change files to capture."
      elsif direction != ahead
        return "Invalid move: pawns can only capture one rank ahead."
      end
    else
      if direction == ahead
        if board[target] == ' '
          return true
        else
          return "Invalid move: pawns cannot capture moving forward."
        end
      elsif ahead == 2 * direction and (from_rank == (@color == :black) ? 7 : 2)
        third = from_rank + direction
        if board[("#{from_file}#{third}").to_sym] != ' '
          return "Invalid move: pawns cannot jump over other pieces."
        elsif board[target] != ' '
          return "Invalid move: pawns cannot capture moving forward."
        else
          return true
        end
      else
        return "Invalid move: pawns can only move two squares in their first move."
      end
    end
  end

  def moves(board)
    # Must return an array of symbols of valid targets
    direction = (@color == :black) ? -1 : 1
    file = @position[0].ord - 97
    rank = @position[1].to_i
    moves = []
    target1 = "#{(file + 97).chr}#{rank + direction}".to_sym
    # If the space ahead of it is clear...
    if board[target1] == ' '
      # The pawn can move into it.
      moves << target1
      # Furthermore, if it is in its original rank...
      if rank == (@color == :black) ? 7 : 2
        target2 = "#{(file + 97).chr}#{rank + 2 * direction}".to_sym
        # ... and the space two ranks ahead is also clear...
        if board[target2] == ' '
          # It can move two ranks.
          moves << target2
        end
      end
    end
    capture1 = "#{(file + 96).chr}#{rank + direction}".to_sym
    capture2 = "#{(file + 98).chr}#{rank + direction}".to_sym
    # If there's an opposing piece in either adjoining file, in the correct rank...
    [capture1, capture2].each do |target|
      if board[target].is_a?(Piece) and board[target].color != @color
        moves << target
      end
    end
    moves
  end

end
