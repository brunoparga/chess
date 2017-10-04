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
        # Assume each moves method returns an array of symbols of possible
        # targets. The king_calling variable is there to prevent an infinite
        # loop in the castling method.
        if not king_calling
          possible[square] = piece.moves(board)
        else
          possible[square] = piece.moves(board) unless piece.is_a?(King)
        end
      end
    end
    possible
  end

  def evade_check(board, color, possible)
    move_hash = possible
    # NOTE These nested enumerators are what's in common between this method and
    # #prune, from 'fubar'. The problem must be here. NOTE
    move_hash.each do |from, move_list|
      helper = move_list.dup
      helper.each do |target|
        hypothetical_board = Board[board]
        hypothetical_board[from].position = target
        hypothetical_board[target] = hypothetical_board[from]
        hypothetical_board[from] = ' '
        if is_check?(hypothetical_board, color)
          move_list.delete(target)
        end
        # This next line is a workaround to a bug that appeared during dev
        @board[from].position = from
      end
      possible.delete(from) if move_list.empty?
    end
    possible
  end

  def puts_in_check?(from, target, board)
    # Verifies if a given move would put the player in check.
    hypothetical_board = Board[board]
    hypothetical_board[from].position = target
    hypothetical_board[target] = hypothetical_board[from]
    hypothetical_board[from] = ' '
    color = board[from].color
    is_check?(hypothetical_board, color)
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
