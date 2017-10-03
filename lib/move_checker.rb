# This module contains methods that take in a board and verify which moves are
# possible for a given side. They are currently needed by the main game class;
# the castling method needs them to see if there are squares under attack, and
# they'll presumably also be needed to see if the king is in check.

module Move_checker

  def possible_moves(board, color)
    # This outputs a hash where the keys are squares and the values are arrays
    # of squares reachable from the key.
    moves = Hash.new([])
    board.each do |square, piece|
      if piece.is_a?(Piece) and piece.color == color
        # Assuming each moves method will return an array of symbols of possible targets
        moves[square] = piece.moves(board)
      end
    end
    moves
  end

  def print_moves(board, possible)
    # This takes in a possible_moves hash and prints it out.
    result = ""
    possible.each do |square, movelist|
      unless movelist.empty?
        result += "#{board[square].to_s.capitalize} at #{square} can move to: #{movelist.join(', ')}\n"
      end
    end
    puts result
  end

end
