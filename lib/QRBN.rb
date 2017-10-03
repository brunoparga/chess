# This file contains four classes, for the Queen, Rook, Bishop and kNight.

require_relative "piece"

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
