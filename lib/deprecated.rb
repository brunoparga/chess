# This file contains functions that won't be needed in the final, "professional"
# version of the game.

module Move_checker

  def print_moves(board, possible)
    # This takes in a possible_moves hash and prints it out.
    result = ""
    possible.each do |square, move_list|
      unless move_list.empty?
        result += "#{board[square].to_s.capitalize} at #{square}/#{board[square].position} can move to: #{move_list.join(' ')}\n"
      end
    end
    puts result
  end

end

class Board < Hash

  def alternate
    # This is a simplified board, for testing purposes. This method should be
    # stored away when dev is done. It can also be replaced once gamestate
    # saving and loading is implemented.
    pieces_order = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    8.times do |file|
      eight = :"#{(97 + file).chr}8"
      one = :"#{(97 + file).chr}1"
      self[eight] = pieces_order[file].new(:black, eight)
      self[one] = pieces_order[file].new(:white, one)
    end
    black_pawns = [:b2, :e7, :f7]
    black_pawns.each do |square|
      self[square] = Pawn.new(:black, square)
    end
    white_pawns = [:c2, :e3, :f2]
    white_pawns.each do |square|
      self[square] = Pawn.new(:white, square)
    end
  end

end

class Piece

  def to_s
    # This is just for display purposes during testing and might go away in prod.
    "#{self.color} #{self.class.to_s.downcase}"
  end
end
