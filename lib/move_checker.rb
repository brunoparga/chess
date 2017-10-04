# This module contains methods that take in a board and verify which moves are
# possible for a given side. They are currently needed by the main game class;
# the castling method needs them to see if there are squares under attack, and
# they'll presumably also be needed to see if the king is in check.

module Move_checker

  def possible_moves(board, color, king_calling = false)
    # This outputs a hash where the keys are squares and the values are arrays
    # of squares reachable from the key.
    possible = Hash.new([])
    board.each do |square, piece|
      if piece.is_a?(Piece) and piece.color == color
        # Assuming each moves method will return an array of symbols of possible targets
        if not king_calling
          possible[square] = piece.moves(board)
        else
          possible[square] = piece.moves(board) unless piece.is_a?(King)
        end
      end
    end
    possible
  end

  def print_moves(board, possible)
    # This takes in a possible_moves hash and prints it out.
    result = ""
    possible.each do |square, movelist|
      unless movelist.empty?
        result += "#{board[square].to_s.capitalize} at #{square}/#{board[square].position} can move to: #{movelist.join(' ')}\n"
      end
    end
    puts result
  end

  def puts_in_check?(from, target, board)
    # Verifies if a given move would put the player in check.
    hypothetical_board = Board[board]
    hypothetical_board[from].position = target
    hypothetical_board[target] = hypothetical_board[from]
    hypothetical_board[from] = ' '
    color = board[from].color
    is_check?(hypothetical_board, color)
    # This call to is_check does not seem to trigger the bug.
  end

  def is_check?(board, color)
    # Verifies if the color given as an argument is in check.
    opponent = (color == :black ? :white : :black)
    opp_possible = possible_moves(board, opponent).values.flatten
    opp_possible.include?(find_king(board, color))
  end

  def find_king(board, color)
    # Returns the position of the king of the given color, to help #is_check?.
    board.each do |square, piece|
      return square if piece.is_a?(King) and piece.color == color
    end
  end

end
